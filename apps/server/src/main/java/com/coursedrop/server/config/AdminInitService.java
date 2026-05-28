package com.coursedrop.server.config;

import java.time.Instant;
import java.util.UUID;

import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.stereotype.Component;

import com.coursedrop.server.dto.AccountResponse;
import com.coursedrop.server.mapper.IdentityRepository;
import com.coursedrop.server.security.PasswordHasher;

@Component
public class AdminInitService implements ApplicationRunner {
    private final AdminProperties adminProperties;
    private final IdentityRepository identityRepository;
    private final PasswordHasher passwordHasher;

    public AdminInitService(
            AdminProperties adminProperties,
            IdentityRepository identityRepository,
            PasswordHasher passwordHasher) {
        this.adminProperties = adminProperties;
        this.identityRepository = identityRepository;
        this.passwordHasher = passwordHasher;
    }

    @Override
    public void run(ApplicationArguments args) {
        if (adminProperties.username() == null || adminProperties.username().isBlank()) {
            return;
        }
        if (adminProperties.password() == null || adminProperties.password().isBlank()) {
            return;
        }
        if (identityRepository.usernameExists(adminProperties.username())) {
            return;
        }
        var now = Instant.now();
        var account = new AccountResponse(UUID.randomUUID().toString(), adminProperties.username(), true, now);
        var hash = passwordHasher.hash(adminProperties.password());
        identityRepository.saveAccount(account, hash.hash(), hash.salt(), hash.algorithm());
        System.out.println("[CourseDrop] Seeded admin account: " + adminProperties.username());
    }
}
