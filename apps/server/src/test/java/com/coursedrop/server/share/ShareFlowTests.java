package com.coursedrop.server.share;

import static org.assertj.core.api.Assertions.assertThat;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.multipart;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.header;
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

        mockMvc.perform(get("/api/shares/{code}/items/{itemId}/download", code, itemId))
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
}
