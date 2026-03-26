package com.vermeg.employee.controller;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.vermeg.employee.dto.LoginRequest;
import com.vermeg.employee.model.Employee;
import com.vermeg.employee.repository.EmployeeRepository;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.ParameterizedTypeReference;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.client.HttpClientErrorException;
import org.springframework.web.client.RestClient;

import java.nio.charset.StandardCharsets;
import java.util.*;

@RestController
@RequestMapping("/api/auth")
public class AuthController {
    private final RestClient restClient;
    private final ObjectMapper objectMapper;
    private final EmployeeRepository employeeRepository;

    @Value("${app.keycloak.token-url}")
    private String tokenUrl;
    @Value("${app.keycloak.server-url}")
    private String keycloakServerUrl;
    @Value("${app.keycloak.realm}")
    private String keycloakRealm;
    @Value("${app.keycloak.admin-user}")
    private String keycloakAdminUser;
    @Value("${app.keycloak.admin-password}")
    private String keycloakAdminPassword;

    public AuthController(ObjectMapper objectMapper, EmployeeRepository employeeRepository) {
        this.restClient = RestClient.create();
        this.objectMapper = objectMapper;
        this.employeeRepository = employeeRepository;
    }

    @PostMapping("/login")
    public ResponseEntity<?> login(@RequestBody LoginRequest req) {
        try {
            Map<String, Object> tokenResp = passwordGrant(req.getEmail(), req.getPassword());
            String accessToken = (String) tokenResp.get("access_token");
            return ResponseEntity.ok(loginResponse(accessToken, req.getEmail()));
        } catch (HttpClientErrorException ex) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(Map.of("error", "Identifiants invalides"));
        }
    }

    @PostMapping("/register")
    public ResponseEntity<?> register(@RequestBody Map<String, Object> payload) {
        String email = Objects.toString(payload.get("email"), "").trim();
        String password = Objects.toString(payload.get("password"), "").trim();
        if (email.isBlank() || password.isBlank()) {
            return ResponseEntity.badRequest().body(Map.of("error", "Email et mot de passe requis"));
        }

        try {
            String adminToken = adminToken();
            String userId = createKeycloakUser(adminToken, payload);
            assignCandidateRole(adminToken, userId);

            try {
                Map<String, Object> tokenResp = passwordGrant(email, password);
                String accessToken = (String) tokenResp.get("access_token");
                return ResponseEntity.ok(loginResponse(accessToken, email));
            } catch (HttpClientErrorException ex) {
                // User created but automatic login failed (ex: direct access grants disabled)
                return ResponseEntity.status(HttpStatus.CREATED)
                        .body(Map.of("status", "created", "message", "Compte cree. Veuillez vous connecter."));
            }
        } catch (HttpClientErrorException ex) {
            if (ex.getStatusCode() == HttpStatus.CONFLICT) {
                return ResponseEntity.status(HttpStatus.CONFLICT).body(Map.of("error", "Email deja utilise"));
            }
            if (ex.getStatusCode() == HttpStatus.UNAUTHORIZED || ex.getStatusCode() == HttpStatus.FORBIDDEN) {
                return ResponseEntity.badRequest().body(Map.of("error", "Configuration Keycloak invalide"));
            }
            return ResponseEntity.badRequest().body(Map.of("error", "Keycloak indisponible"));
        }
    }

    @GetMapping("/me")
    public ResponseEntity<?> me(Authentication authentication) {
        String email = authentication.getName();
        Employee employee = employeeRepository.findByEmail(email).orElseGet(() -> {
            Employee e = new Employee();
            e.setEmail(email);
            e.setFullName(email);
            e.setRole("EMPLOYEE");
            return employeeRepository.save(e);
        });
        if (!"CANDIDATE".equals(employee.getRole()) && (employee.getDepartment() == null || employee.getDepartment().isBlank())) {
            employee.setDepartment("Non defini");
            employeeRepository.save(employee);
        }
        return ResponseEntity.ok(Map.of("user", toUserMap(employee)));
    }

    @PreAuthorize("hasRole('HR_ADMIN')")
    @PostMapping("/admin/create-user")
    public ResponseEntity<?> createUser(@RequestBody Map<String, Object> payload) {
        String email = Objects.toString(payload.get("email"), "").trim();
        String password = Objects.toString(payload.get("password"), "").trim();
        String fullName = Objects.toString(payload.get("full_name"), email).trim();
        String role = Objects.toString(payload.get("role"), "EMPLOYEE").toUpperCase();
        String department = Objects.toString(payload.get("department"), "").trim();
        Long managerId = payload.get("manager_id") == null ? null : Long.parseLong(Objects.toString(payload.get("manager_id")));
        if (email.isBlank() || password.isBlank()) {
            return ResponseEntity.badRequest().body(Map.of("error", "Email et mot de passe requis"));
        }
        if (!List.of("EMPLOYEE", "MANAGER", "HR_ADMIN", "RECRUITER", "CANDIDATE").contains(role)) {
            role = "EMPLOYEE";
        }
        if (!"CANDIDATE".equals(role) && department.isBlank()) {
            return ResponseEntity.badRequest().body(Map.of("error", "Departement requis pour ce role"));
        }
        if ("MANAGER".equals(role) && department.isBlank()) {
            return ResponseEntity.badRequest().body(Map.of("error", "Un manager doit avoir un departement"));
        }
        if (managerId != null) {
            Employee manager = employeeRepository.findById(managerId).orElse(null);
            if (manager == null || !"MANAGER".equals(manager.getRole())) {
                return ResponseEntity.badRequest().body(Map.of("error", "Manager invalide"));
            }
            if (manager.getDepartment() == null || manager.getDepartment().isBlank()) {
                return ResponseEntity.badRequest().body(Map.of("error", "Le manager doit avoir un departement"));
            }
            if (department.isBlank()) {
                department = manager.getDepartment();
            } else if (!manager.getDepartment().equalsIgnoreCase(department)) {
                return ResponseEntity.badRequest().body(Map.of("error", "Le departement doit correspondre a celui du manager"));
            }
        }
        try {
            String adminToken = adminToken();
            Map<String, Object> userPayload = new HashMap<>(payload);
            userPayload.put("full_name", fullName);
            String userId = createKeycloakUser(adminToken, userPayload);
            assignRealmRole(adminToken, userId, role);

            Employee emp = employeeRepository.findByEmail(email).orElseGet(Employee::new);
            emp.setEmail(email);
            emp.setFullName(fullName);
            emp.setRole(role);
            emp.setDepartment(department);
            emp.setManagerId("MANAGER".equals(role) ? null : managerId);
            if (emp.getLeaveBalance() == null) emp.setLeaveBalance(25);
            if (emp.getTotalHours() == null) emp.setTotalHours(0);
            employeeRepository.save(emp);
            return ResponseEntity.ok(Map.of("user", toUserMap(emp)));
        } catch (HttpClientErrorException ex) {
            return ResponseEntity.badRequest().body(Map.of("error", "Creation impossible: email deja utilise ou Keycloak indisponible"));
        }
    }

    @PutMapping("/profile")
    public ResponseEntity<?> updateProfile(Authentication authentication, @RequestBody Map<String, Object> payload) {
        String email = authentication.getName();
        Employee employee = employeeRepository.findByEmail(email).orElseGet(Employee::new);

        employee.setEmail(email);
        employee.setFullName(Objects.toString(payload.getOrDefault("full_name", employee.getFullName()), employee.getFullName()));
        String department = Objects.toString(payload.getOrDefault("department", employee.getDepartment()), employee.getDepartment());
        if (!"CANDIDATE".equals(employee.getRole()) && (department == null || department.isBlank())) {
            return ResponseEntity.badRequest().body(Map.of("error", "Departement requis"));
        }
        employee.setDepartment(department);
        employee.setPosition((String) payload.getOrDefault("position", employee.getPosition()));
        employee.setPhone((String) payload.getOrDefault("phone", employee.getPhone()));
        employee.setCountry((String) payload.getOrDefault("country", employee.getCountry()));
        employee.setCity((String) payload.getOrDefault("city", employee.getCity()));
        employee.setDiploma((String) payload.getOrDefault("diploma", employee.getDiploma()));
        if (payload.containsKey("avatar_base64")) {
            employee.setAvatarUrl(Objects.toString(payload.get("avatar_base64"), employee.getAvatarUrl()));
        }

        Employee saved = employeeRepository.save(employee);
        return ResponseEntity.ok(Map.of("user", toUserMap(saved)));
    }

    private String adminToken() {
        Map<String, Object> tokenResp = restClient.post()
                .uri(keycloakServerUrl + "/realms/master/protocol/openid-connect/token")
                .contentType(MediaType.APPLICATION_FORM_URLENCODED)
                .body("grant_type=password&client_id=admin-cli&username=" + keycloakAdminUser + "&password=" + keycloakAdminPassword)
                .retrieve()
                .body(new ParameterizedTypeReference<Map<String, Object>>() {});
        return (String) tokenResp.get("access_token");
    }

    private String createKeycloakUser(String adminToken, Map<String, Object> payload) {
        String email = Objects.toString(payload.get("email"), "");
        Map<String, Object> user = new HashMap<>();
        user.put("username", email);
        user.put("email", email);
        user.put("enabled", true);
        user.put("emailVerified", true);
        user.put("firstName", firstName(Objects.toString(payload.get("full_name"), email)));
        user.put("lastName", lastName(Objects.toString(payload.get("full_name"), "")));
        user.put("credentials", List.of(Map.of("type", "password", "value", Objects.toString(payload.get("password"), ""), "temporary", false)));

        ResponseEntity<Void> created = restClient.post()
                .uri(keycloakServerUrl + "/admin/realms/" + keycloakRealm + "/users")
                .header("Authorization", "Bearer " + adminToken)
                .contentType(MediaType.APPLICATION_JSON)
                .body(user)
                .retrieve()
                .toBodilessEntity();

        String location = created.getHeaders().getFirst("Location");
        if (location == null || !location.contains("/users/")) throw new HttpClientErrorException(HttpStatus.BAD_REQUEST);
        return location.substring(location.lastIndexOf('/') + 1);
    }

    private void assignCandidateRole(String adminToken, String userId) {
        assignRealmRole(adminToken, userId, "CANDIDATE");
    }

    private void assignRealmRole(String adminToken, String userId, String roleName) {
        Map<String, Object> role = restClient.get()
                .uri(keycloakServerUrl + "/admin/realms/" + keycloakRealm + "/roles/" + roleName)
                .header("Authorization", "Bearer " + adminToken)
                .retrieve()
                .body(new ParameterizedTypeReference<Map<String, Object>>() {});

        restClient.post()
                .uri(keycloakServerUrl + "/admin/realms/" + keycloakRealm + "/users/" + userId + "/role-mappings/realm")
                .header("Authorization", "Bearer " + adminToken)
                .contentType(MediaType.APPLICATION_JSON)
                .body(List.of(role))
                .retrieve()
                .toBodilessEntity();
    }

    private Map<String, Object> passwordGrant(String username, String password) {
        return restClient.post()
                .uri(tokenUrl)
                .contentType(MediaType.APPLICATION_FORM_URLENCODED)
                .body("grant_type=password&client_id=sirh-frontend&username=" + username + "&password=" + password)
                .retrieve()
                .body(new ParameterizedTypeReference<Map<String, Object>>() {});
    }

    private Map<String, Object> loginResponse(String accessToken, String fallbackEmail) {
        Map<String, Object> claims = decodeJwt(accessToken);
        String email = stringClaim(claims, "preferred_username", fallbackEmail);
        String name = stringClaim(claims, "name", email);
        String role = extractRole(claims);

        Employee employee = employeeRepository.findByEmail(email).orElseGet(Employee::new);
        employee.setEmail(email);
        employee.setFullName(name);
        employee.setRole(role);
        if (!"CANDIDATE".equals(role) && (employee.getDepartment() == null || employee.getDepartment().isBlank())) {
            employee.setDepartment("Non defini");
        }
        if (employee.getLeaveBalance() == null) employee.setLeaveBalance(25);
        if (employee.getTotalHours() == null) employee.setTotalHours(0);
        Employee saved = employeeRepository.save(employee);

        return Map.of("token", accessToken, "user", toUserMap(saved));
    }

    private Map<String, Object> toUserMap(Employee e) {
        Map<String, Object> user = new HashMap<>();
        user.put("id", e.getId());
        user.put("email", e.getEmail());
        user.put("full_name", e.getFullName());
        user.put("role", e.getRole() == null ? "EMPLOYEE" : e.getRole());
        user.put("department", e.getDepartment());
        user.put("position", e.getPosition());
        user.put("experience", e.getExperience());
        user.put("leave_balance", e.getLeaveBalance());
        user.put("total_hours", e.getTotalHours());
        user.put("phone", e.getPhone());
        user.put("country", e.getCountry());
        user.put("city", e.getCity());
        user.put("diploma", e.getDiploma());
        user.put("manager_id", e.getManagerId());
        user.put("salary", e.getSalary());
        user.put("contract_type", e.getContractType());
        user.put("avatar_url", e.getAvatarUrl());
        return user;
    }

    private Map<String, Object> decodeJwt(String jwt) {
        try {
            String[] parts = jwt.split("\\.");
            String payload = new String(Base64.getUrlDecoder().decode(parts[1]), StandardCharsets.UTF_8);
            return objectMapper.readValue(payload, new TypeReference<Map<String, Object>>() {});
        } catch (Exception e) {
            return Map.of();
        }
    }

    private String extractRole(Map<String, Object> claims) {
        Object realmAccessObj = claims.get("realm_access");
        if (realmAccessObj instanceof Map<?, ?> realmAccess) {
            Object rolesObj = realmAccess.get("roles");
            if (rolesObj instanceof List<?> roles) {
                if (roles.contains("HR_ADMIN")) return "HR_ADMIN";
                if (roles.contains("MANAGER")) return "MANAGER";
                if (roles.contains("RECRUITER")) return "RECRUITER";
                if (roles.contains("CANDIDATE")) return "CANDIDATE";
                if (roles.contains("EMPLOYEE")) return "EMPLOYEE";
            }
        }
        return "EMPLOYEE";
    }

    private String stringClaim(Map<String, Object> claims, String key, String fallback) {
        Object value = claims.get(key);
        return value == null ? fallback : value.toString();
    }

    private String firstName(String fullName) {
        String[] parts = fullName.trim().split("\\s+");
        return parts.length == 0 ? fullName : parts[0];
    }

    private String lastName(String fullName) {
        String[] parts = fullName.trim().split("\\s+");
        if (parts.length <= 1) return "";
        return String.join(" ", Arrays.copyOfRange(parts, 1, parts.length));
    }
}
