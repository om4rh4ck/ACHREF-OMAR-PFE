package com.vermeg.employee.controller;

import com.vermeg.employee.model.*;
import com.vermeg.employee.repository.*;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.*;

@RestController
public class CompatibilityController {

    private final EmployeeRepository employeeRepository;
    private final MessageRepository messageRepository;
    private final NewsRepository newsRepository;
    private final NotificationRepository notificationRepository;
    private final DepartmentRepository departmentRepository;
    private final ContractTypeRepository contractTypeRepository;
    private final PositionRepository positionRepository;
    private final LeaveRequestRepository leaveRequestRepository;
    private final DocumentRequestRepository documentRequestRepository;

    public CompatibilityController(
            EmployeeRepository employeeRepository,
            MessageRepository messageRepository,
            NewsRepository newsRepository,
            NotificationRepository notificationRepository,
            DepartmentRepository departmentRepository,
            ContractTypeRepository contractTypeRepository,
            PositionRepository positionRepository,
            LeaveRequestRepository leaveRequestRepository,
            DocumentRequestRepository documentRequestRepository
    ) {
        this.employeeRepository = employeeRepository;
        this.messageRepository = messageRepository;
        this.newsRepository = newsRepository;
        this.notificationRepository = notificationRepository;
        this.departmentRepository = departmentRepository;
        this.contractTypeRepository = contractTypeRepository;
        this.positionRepository = positionRepository;
        this.leaveRequestRepository = leaveRequestRepository;
        this.documentRequestRepository = documentRequestRepository;
    }

    @GetMapping("/api/hr-admins")
    public List<Map<String, Object>> hrAdmins(Authentication authentication) {
        Employee me = current(authentication);
        if (me == null) return List.of();
        if ("HR_ADMIN".equals(me.getRole())) {
            return employeeRepository.findAll().stream().filter(u -> !Objects.equals(u.getId(), me.getId())).map(this::userLite).toList();
        }
        return employeeRepository.findByRole("HR_ADMIN").stream().map(this::userLite).toList();
    }

    @GetMapping("/api/messages")
    public List<Map<String, Object>> messages(Authentication authentication) {
        Employee me = current(authentication);
        if (me == null) return List.of();
        Map<Long, Employee> users = new HashMap<>();
        employeeRepository.findAll().forEach(u -> users.put(u.getId(), u));
        return messageRepository.findBySenderIdOrReceiverIdOrderByCreatedAtAsc(me.getId(), me.getId()).stream().map(m -> {
            Map<String, Object> row = new HashMap<>();
            row.put("id", m.getId());
            row.put("sender_id", m.getSenderId());
            row.put("receiver_id", m.getReceiverId());
            row.put("content", m.getContent());
            row.put("created_at", m.getCreatedAt());
            row.put("is_read", Boolean.TRUE.equals(m.getIsRead()));
            Employee sender = users.get(m.getSenderId());
            row.put("sender_name", sender == null ? "Unknown" : sender.getFullName());
            return row;
        }).toList();
    }

    @PutMapping("/api/messages/{id}/read")
    public ResponseEntity<?> markMessageRead(Authentication authentication, @PathVariable Long id) {
        Employee me = current(authentication);
        if (me == null) return ResponseEntity.status(401).build();
        return messageRepository.findById(id).map(m -> {
            if (!Objects.equals(m.getReceiverId(), me.getId())) return ResponseEntity.status(403).build();
            m.setIsRead(true);
            messageRepository.save(m);
            return ResponseEntity.ok(Map.of("ok", true));
        }).orElse(ResponseEntity.notFound().build());
    }

    @PostMapping("/api/messages")
    public ResponseEntity<?> sendMessage(Authentication authentication, @RequestBody Map<String, Object> payload) {
        Employee me = current(authentication);
        if (me == null) return ResponseEntity.status(401).build();
        Long receiverId = Long.parseLong(payload.get("receiver_id").toString());
        if ("CANDIDATE".equals(me.getRole())) {
            Employee receiver = employeeRepository.findById(receiverId).orElse(null);
            if (receiver == null || !"HR_ADMIN".equals(receiver.getRole())) {
                return ResponseEntity.status(403).body(Map.of("error", "Acces refuse"));
            }
        }
        MessageEntity m = new MessageEntity();
        m.setSenderId(me.getId());
        m.setReceiverId(receiverId);
        m.setContent(Objects.toString(payload.get("content"), ""));
        return ResponseEntity.ok(messageRepository.save(m));
    }

    @GetMapping("/api/news")
    public List<Map<String, Object>> news() {
        Map<Long, Employee> users = new HashMap<>();
        employeeRepository.findAll().forEach(u -> users.put(u.getId(), u));
        return newsRepository.findAllByOrderByCreatedAtDesc().stream().map(n -> {
            Map<String, Object> row = new HashMap<>();
            row.put("id", n.getId());
            row.put("title", n.getTitle());
            row.put("content", n.getContent());
            row.put("author_id", n.getAuthorId());
            row.put("created_at", n.getCreatedAt());
            Employee author = users.get(n.getAuthorId());
            row.put("author_name", author == null ? "RH" : author.getFullName());
            return row;
        }).toList();
    }

    @PreAuthorize("hasAnyRole('HR_ADMIN','MANAGER','RECRUITER')")
    @PostMapping("/api/news")
    public ResponseEntity<?> addNews(Authentication authentication, @RequestBody Map<String, Object> payload) {
        Employee me = current(authentication);
        if (me == null) return ResponseEntity.status(401).build();
        NewsItem n = new NewsItem();
        n.setTitle(Objects.toString(payload.get("title"), ""));
        n.setContent(Objects.toString(payload.get("content"), ""));
        n.setAuthorId(me.getId());
        return ResponseEntity.ok(newsRepository.save(n));
    }

    @GetMapping("/api/notifications")
    public List<NotificationEntity> notifications(Authentication authentication) {
        Employee me = current(authentication);
        if (me == null) return List.of();
        return notificationRepository.findByUserIdOrderByCreatedAtDesc(me.getId());
    }

    @PreAuthorize("hasAnyRole('HR_ADMIN','MANAGER','RECRUITER')")
    @PostMapping("/api/notifications")
    public ResponseEntity<?> addNotification(@RequestBody Map<String, Object> payload) {
        NotificationEntity notification = new NotificationEntity();
        notification.setUserId(Long.parseLong(Objects.toString(payload.get("user_id"))));
        notification.setMessage(Objects.toString(payload.get("message"), ""));
        notification.setType(Objects.toString(payload.getOrDefault("type", "INFO"), "INFO"));
        notification.setIsRead(false);
        return ResponseEntity.ok(notificationRepository.save(notification));
    }

    @PutMapping("/api/notifications/{id}/read")
    public ResponseEntity<?> markRead(Authentication authentication, @PathVariable Long id) {
        Employee me = current(authentication);
        if (me == null) return ResponseEntity.status(401).build();
        return notificationRepository.findById(id).map(n -> {
            if (!Objects.equals(n.getUserId(), me.getId())) return ResponseEntity.status(403).build();
            n.setIsRead(true);
            notificationRepository.save(n);
            return ResponseEntity.ok(Map.of("ok", true));
        }).orElse(ResponseEntity.notFound().build());
    }

    @GetMapping("/api/stats")
    public Map<String, Object> stats() {
        long employees = employeeRepository.findAll().stream().filter(u -> !"CANDIDATE".equals(u.getRole())).count();
        Map<String, Long> perDept = new LinkedHashMap<>();
        employeeRepository.findAll().forEach(u -> {
            String d = (u.getDepartment() == null || u.getDepartment().isBlank()) ? "N/A" : u.getDepartment();
            perDept.put(d, perDept.getOrDefault(d, 0L) + 1);
        });
        List<Map<String, Object>> departmentStats = perDept.entrySet().stream().map(e -> {
            Map<String, Object> row = new HashMap<>();
            row.put("department", e.getKey());
            row.put("count", e.getValue());
            return row;
        }).toList();
        return Map.of(
                "employees", employees,
                "openJobs", 0,
                "totalApplications", 0,
                "departmentStats", departmentStats,
                "mobilityRate", "18%",
                "avgRecruitmentTime", "21 jours"
        );
    }

    @GetMapping("/api/team")
    public List<Employee> team(Authentication authentication) {
        Employee me = current(authentication);
        if (me == null || me.getId() == null) return List.of();
        return employeeRepository.findByManagerId(me.getId());
    }

    @GetMapping("/api/team/stats")
    public Map<String, Object> teamStats(Authentication authentication) {
        Employee me = current(authentication);
        if (me == null || me.getId() == null) return Map.of();
        int teamSize = employeeRepository.findByManagerId(me.getId()).size();
        int pendingLeaves = leaveRequestRepository.findByStatusOrderByCreatedAtDesc("PENDING").size();
        return Map.of("teamSize", teamSize, "pendingLeaves", pendingLeaves, "performanceAvg", "89%", "trainingCompletion", "76%");
    }

    @GetMapping("/api/departments")
    public List<DepartmentEntity> departments() { return departmentRepository.findAll(); }

    @PreAuthorize("hasRole('HR_ADMIN')")
    @PostMapping("/api/departments")
    public ResponseEntity<?> addDepartment(@RequestBody DepartmentEntity dto) { return ResponseEntity.ok(departmentRepository.save(dto)); }

    @GetMapping("/api/positions")
    public List<PositionEntity> positions() { return positionRepository.findAll(); }

    @PreAuthorize("hasRole('HR_ADMIN')")
    @PostMapping("/api/positions")
    public ResponseEntity<?> addPosition(@RequestBody PositionEntity dto) { return ResponseEntity.ok(positionRepository.save(dto)); }

    @PreAuthorize("hasRole('HR_ADMIN')")
    @DeleteMapping("/api/positions/{id}")
    public ResponseEntity<?> deletePosition(@PathVariable Long id) {
        if (!positionRepository.existsById(id)) return ResponseEntity.notFound().build();
        positionRepository.deleteById(id);
        return ResponseEntity.noContent().build();
    }

    @GetMapping("/api/users")
    public List<Employee> users() { return employeeRepository.findAll(); }

    @PreAuthorize("hasRole('HR_ADMIN')")
    @PutMapping("/api/users/{id}/role")
    public ResponseEntity<?> updateRole(@PathVariable Long id, @RequestBody Map<String, Object> payload) {
        return employeeRepository.findById(id).map(u -> {
            String role = Objects.toString(payload.get("role"), u.getRole());
            if ("MANAGER".equals(role) && (u.getDepartment() == null || u.getDepartment().isBlank())) {
                return ResponseEntity.badRequest().body(Map.of("error", "Un manager doit avoir un departement"));
            }
            u.setRole(role);
            if ("MANAGER".equals(role)) {
                u.setManagerId(null);
            }
            return ResponseEntity.ok(employeeRepository.save(u));
        }).orElse(ResponseEntity.notFound().build());
    }

    @PreAuthorize("hasAnyRole('HR_ADMIN','MANAGER')")
    @DeleteMapping("/api/users/{id}")
    public ResponseEntity<?> deleteUser(Authentication authentication, @PathVariable Long id) {
        Employee me = current(authentication);
        if (me == null) return ResponseEntity.status(401).build();
        if (Objects.equals(me.getId(), id)) return ResponseEntity.badRequest().body(Map.of("error", "Suppression impossible"));

        return employeeRepository.findById(id).map(target -> {
            if (leaveRequestRepository.existsByUserIdAndStatus(id, "PENDING")
                    || documentRequestRepository.existsByUserIdAndStatus(id, "PENDING")) {
                return ResponseEntity.status(409).body(Map.of("error", "Demandes en cours"));
            }
            if ("MANAGER".equals(me.getRole())) {
                if (!Objects.equals(target.getManagerId(), me.getId())) {
                    return ResponseEntity.status(403).body(Map.of("error", "Acces refuse"));
                }
                if (!"EMPLOYEE".equals(target.getRole())) {
                    return ResponseEntity.status(403).body(Map.of("error", "Seuls les employes peuvent etre supprimes"));
                }
            }
            if ("HR_ADMIN".equals(target.getRole())) {
                return ResponseEntity.status(403).body(Map.of("error", "Impossible de supprimer un HR_ADMIN"));
            }
            employeeRepository.deleteById(id);
            return ResponseEntity.noContent().build();
        }).orElse(ResponseEntity.notFound().build());
    }

    @PreAuthorize("hasRole('HR_ADMIN')")
    @PutMapping("/api/users/{id}")
    public ResponseEntity<?> updateUser(@PathVariable Long id, @RequestBody Map<String, Object> payload) {
        return employeeRepository.findById(id).map(u -> {
            String department = Objects.toString(payload.getOrDefault("department", u.getDepartment()), u.getDepartment());
            String position = Objects.toString(payload.getOrDefault("position", u.getPosition()), u.getPosition());
            String contractType = payload.containsKey("contract_type")
                    ? Objects.toString(payload.get("contract_type"), u.getContractType())
                    : u.getContractType();
            Double salary = payload.containsKey("salary")
                    ? Double.valueOf(Objects.toString(payload.get("salary")))
                    : u.getSalary();
            boolean managerProvided = payload.containsKey("manager_id");
            Long managerId = managerProvided && payload.get("manager_id") == null
                    ? null
                    : (payload.get("manager_id") == null ? u.getManagerId() : Long.parseLong(Objects.toString(payload.get("manager_id"))));

            if (!"CANDIDATE".equals(u.getRole()) && (department == null || department.isBlank())) {
                return ResponseEntity.badRequest().body(Map.of("error", "Departement requis"));
            }
            if ("MANAGER".equals(u.getRole()) && (department == null || department.isBlank())) {
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
                if (department == null || department.isBlank()) {
                    department = manager.getDepartment();
                } else if (!manager.getDepartment().equalsIgnoreCase(department)) {
                    return ResponseEntity.badRequest().body(Map.of("error", "Le departement doit correspondre a celui du manager"));
                }
            }

            if ("MANAGER".equals(u.getRole())) {
                managerId = null;
            }

            u.setDepartment(department);
            u.setPosition(position);
            if (managerProvided) {
                u.setManagerId(managerId);
            }
            if ("EMPLOYEE".equals(u.getRole())) {
                u.setContractType(contractType);
                u.setSalary(salary);
            }
            return ResponseEntity.ok(employeeRepository.save(u));
        }).orElse(ResponseEntity.notFound().build());
    }

    @GetMapping("/api/contract-types")
    public List<ContractTypeEntity> contractTypes() { return contractTypeRepository.findAll(); }

    @PreAuthorize("hasRole('HR_ADMIN')")
    @PostMapping("/api/contract-types")
    public ResponseEntity<?> addContractType(@RequestBody ContractTypeEntity dto) { return ResponseEntity.ok(contractTypeRepository.save(dto)); }

    private Employee current(Authentication authentication) {
        if (authentication == null) return null;
        return employeeRepository.findByEmail(authentication.getName()).orElse(null);
    }

    private Map<String, Object> userLite(Employee e) {
        Map<String, Object> row = new HashMap<>();
        row.put("id", e.getId());
        row.put("full_name", e.getFullName());
        row.put("email", e.getEmail());
        row.put("role", e.getRole());
        return row;
    }
}
