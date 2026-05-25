package com.coursedrop.server.share;

import static org.assertj.core.api.Assertions.assertThat;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.delete;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.multipart;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.header;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.content;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.mock.web.MockMultipartFile;
import org.springframework.test.web.servlet.MockMvc;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;

@SpringBootTest
@AutoConfigureMockMvc
class ShareFlowTests {
    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    @Test
    void shareCanUploadAndDownloadThroughAppEndpoint() throws Exception {
        var fingerprintResult = mockMvc.perform(post("/api/identity/fingerprints")
                .contentType(MediaType.APPLICATION_JSON)
                .content("""
                        {
                          "fingerprint": "test-device-share-flow",
                          "deviceName": "Test Phone",
                          "platform": "HarmonyOS"
                        }
                        """))
                .andExpect(status().isOk())
                .andReturn();
        var fingerprintId = objectMapper.readTree(fingerprintResult.getResponse().getContentAsString()).get("id").asText();

        var createResult = mockMvc.perform(post("/api/shares")
                .contentType(MediaType.APPLICATION_JSON)
                .content("""
                        {
                          "expireHours": 1,
                          "downloadAuthRequired": true,
                          "ownerIdentityId": "%s",
                          "ownerIdentityType": "FINGERPRINT"
                        }
                        """.formatted(fingerprintId)))
                .andExpect(status().isOk())
                .andReturn();
        JsonNode share = objectMapper.readTree(createResult.getResponse().getContentAsString());
        var shareId = share.get("id").asText();
        var code = share.get("code").asText();
        assertThat(share.get("downloadUrl").asText()).isEqualTo("/s/" + code);

        var file = new MockMultipartFile(
                "file",
                "hello.txt",
                "text/plain",
                "hello coursedrop".getBytes());
        var uploadResult = mockMvc.perform(multipart("/api/shares/{shareId}/items", shareId)
                .file(file)
                .param("encrypted", "false")
                .param("sha256", "sample"))
                .andExpect(status().isOk())
                .andReturn();
        JsonNode item = objectMapper.readTree(uploadResult.getResponse().getContentAsString());
        var itemId = item.get("id").asText();

        mockMvc.perform(get("/api/shares/{code}", code))
                .andExpect(status().isOk());

        mockMvc.perform(get("/api/shares/{code}/items/{itemId}/download", code, itemId)
                .header("X-CourseDrop-Fingerprint-Id", fingerprintId))
                .andExpect(status().isOk())
                .andExpect(header().string(HttpHeaders.CONTENT_DISPOSITION,
                        "attachment; filename*=UTF-8''hello.txt"));
    }

    @Test
    void browserDownloadRequiresAuthorizationHeader() throws Exception {
        var createResult = mockMvc.perform(post("/api/shares")
                .contentType(MediaType.APPLICATION_JSON)
                .content("""
                        {
                          "expireHours": 1,
                          "downloadAuthRequired": false,
                          "ownerIdentityType": "ANONYMOUS"
                        }
                        """))
                .andExpect(status().isOk())
                .andReturn();
        JsonNode share = objectMapper.readTree(createResult.getResponse().getContentAsString());
        var shareId = share.get("id").asText();
        var code = share.get("code").asText();

        var file = new MockMultipartFile("file", "locked.txt", "text/plain", "locked".getBytes());
        var uploadResult = mockMvc.perform(multipart("/api/shares/{shareId}/items", shareId).file(file))
                .andExpect(status().isOk())
                .andReturn();
        JsonNode item = objectMapper.readTree(uploadResult.getResponse().getContentAsString());
        var itemId = item.get("id").asText();

        mockMvc.perform(get("/s/{code}/items/{itemId}/download", code, itemId))
                .andExpect(status().isUnauthorized());

        mockMvc.perform(get("/s/{code}/items/{itemId}/download", code, itemId)
                .header("X-CourseDrop-Web-Authorized", "true"))
                .andExpect(status().isOk());
    }

    @Test
    void browserDownloadPageRendersTailwindLoginSurface() throws Exception {
        var createResult = mockMvc.perform(post("/api/shares")
                .contentType(MediaType.APPLICATION_JSON)
                .content("""
                        {
                          "expireHours": 1,
                          "downloadAuthRequired": true,
                          "ownerIdentityType": "ANONYMOUS"
                        }
                        """))
                .andExpect(status().isOk())
                .andReturn();
        var code = objectMapper.readTree(createResult.getResponse().getContentAsString()).get("code").asText();

        mockMvc.perform(get("/s/{code}", code))
                .andExpect(status().isOk())
                .andExpect(content().string(org.hamcrest.Matchers.containsString("https://cdn.tailwindcss.com")))
                .andExpect(content().string(org.hamcrest.Matchers.containsString("登录并下载到电脑")));
    }


    @Test
    void encryptedUploadRequiresCompleteMetadata() throws Exception {
        var createResult = mockMvc.perform(post("/api/shares")
                .contentType(MediaType.APPLICATION_JSON)
                .content("""
                        {
                          "expireHours": 1,
                          "downloadAuthRequired": false,
                          "ownerIdentityType": "ANONYMOUS"
                        }
                        """))
                .andExpect(status().isOk())
                .andReturn();
        var shareId = objectMapper.readTree(createResult.getResponse().getContentAsString()).get("id").asText();
        var file = new MockMultipartFile("file", "encrypted.bin", "application/octet-stream", "cipher".getBytes());

        mockMvc.perform(multipart("/api/shares/{shareId}/items", shareId)
                .file(file)
                .param("encrypted", "true"))
                .andExpect(status().isBadRequest());
    }

    @Test
    void webLoginConfirmationIssuesCookie() throws Exception {
        var fingerprintResult = mockMvc.perform(post("/api/identity/fingerprints")
                .contentType(MediaType.APPLICATION_JSON)
                .content("""
                        {
                          "fingerprint": "test-device-web-login",
                          "deviceName": "Login Phone",
                          "platform": "HarmonyOS"
                        }
                        """))
                .andExpect(status().isOk())
                .andReturn();
        var fingerprintId = objectMapper.readTree(fingerprintResult.getResponse().getContentAsString()).get("id").asText();

        var createLogin = mockMvc.perform(post("/api/auth/web-login"))
                .andExpect(status().isOk())
                .andReturn();
        var loginCode = objectMapper.readTree(createLogin.getResponse().getContentAsString()).get("loginCode").asText();

        mockMvc.perform(post("/api/auth/web-login/{loginCode}/confirm", loginCode)
                .contentType(MediaType.APPLICATION_JSON)
                .content("""
                        {
                          "fingerprintId": "%s"
                        }
                        """.formatted(fingerprintId)))
                .andExpect(status().isOk());

        mockMvc.perform(get("/api/auth/web-login/{loginCode}", loginCode))
                .andExpect(status().isOk())
                .andExpect(header().exists(HttpHeaders.SET_COOKIE));
    }

    @Test
    void shareCanBeExtendedAndItemCanBeDeleted() throws Exception {
        var createResult = mockMvc.perform(post("/api/shares")
                .contentType(MediaType.APPLICATION_JSON)
                .content("""
                        {
                          "expireHours": 1,
                          "downloadAuthRequired": false,
                          "ownerIdentityId": "owner-1",
                          "ownerIdentityType": "FINGERPRINT"
                        }
                        """))
                .andExpect(status().isOk())
                .andReturn();
        var share = objectMapper.readTree(createResult.getResponse().getContentAsString());
        var shareId = share.get("id").asText();

        mockMvc.perform(post("/api/shares/{shareId}/expiry", shareId)
                .contentType(MediaType.APPLICATION_JSON)
                .content("""
                        {
                          "expireHours": 2
                        }
                        """))
                .andExpect(status().isOk());

        var file = new MockMultipartFile("file", "remove.txt", "text/plain", "remove".getBytes());
        var uploadResult = mockMvc.perform(multipart("/api/shares/{shareId}/items", shareId).file(file))
                .andExpect(status().isOk())
                .andReturn();
        var itemId = objectMapper.readTree(uploadResult.getResponse().getContentAsString()).get("id").asText();

        mockMvc.perform(delete("/api/shares/{shareId}/items/{itemId}", shareId, itemId)
                .header("X-CourseDrop-Fingerprint-Id", "owner-1"))
                .andExpect(status().isNoContent());
    }
}
