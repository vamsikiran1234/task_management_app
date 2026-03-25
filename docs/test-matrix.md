# Test Matrix (Phase 0)

## 1. Model and Validation
| ID | Scenario | Type | Expected Result |
|---|---|---|---|
| TM-01 | Create task with all valid fields | API | 201 Created |
| TM-02 | Missing title | API | 400 with title required |
| TM-03 | Missing description | API | 400 with description required |
| TM-04 | Missing due_date | API | 400 with due_date required |
| TM-05 | Invalid status value | API | 400 invalid choice |
| TM-06 | blocked_by non-existent id | API | 400 invalid reference |
| TM-07 | blocked_by self id | API | 400 self-blocking error |
| TM-08 | Circular dependency attempt | API | 400 circular dependency error |

## 2. CRUD Behavior
| ID | Scenario | Type | Expected Result |
|---|---|---|---|
| TM-09 | Read full list with no filters | API/UI | All tasks returned/displayed |
| TM-10 | Update title only | API/UI | 200 and title updated |
| TM-11 | Update status transition TO_DO -> DONE | API/UI | 200 and status updated |
| TM-12 | Delete task with no dependents | API/UI | 204 and removed from list |
| TM-13 | Delete task with dependents | API/UI | 409 or 400 with dependency error |

## 3. Dependency UI Behavior
| ID | Scenario | Type | Expected Result |
|---|---|---|---|
| TM-14 | Child blocked by parent not DONE | UI | Child card appears blocked style |
| TM-15 | Parent switched to DONE | UI | Child card style updates to unblocked |
| TM-16 | Parent switched DONE back to IN_PROGRESS | UI | Child card returns to blocked style |

## 4. Draft Persistence
| ID | Scenario | Type | Expected Result |
|---|---|---|---|
| TM-17 | Enter draft then navigate back | UI | Draft restored on reopen |
| TM-18 | Enter draft then minimize/restore app | UI | Draft remains |
| TM-19 | Save draft successfully | UI | Draft cleared |
| TM-20 | Cancel with explicit clear action | UI | Draft removed |

## 5. Search and Filter
| ID | Scenario | Type | Expected Result |
|---|---|---|---|
| TM-21 | Search exact title | API/UI | Matching tasks only |
| TM-22 | Search partial case-insensitive | API/UI | Matching tasks only |
| TM-23 | Filter by status DONE | API/UI | DONE tasks only |
| TM-24 | Search plus status filter | API/UI | Intersection of both conditions |
| TM-25 | Search no results | UI | Empty-state message shown |

## 6. Async Save Delay and Concurrency Guard
| ID | Scenario | Type | Expected Result |
|---|---|---|---|
| TM-26 | Create request duration | API/UI | Response delayed about 2s |
| TM-27 | Update request duration | API/UI | Response delayed about 2s |
| TM-28 | Double tap Save during in-flight request | UI | Single request fired |
| TM-29 | Attempt form edits during save | UI | Form remains stable, no duplicate submit |

## 7. Resilience and Error Handling
| ID | Scenario | Type | Expected Result |
|---|---|---|---|
| TM-30 | Backend 400 validation error | UI | Inline/form error message visible |
| TM-31 | Backend 500 error | UI | Retry-capable error banner/state |
| TM-32 | Network timeout | UI | Timeout message, no app crash |
| TM-33 | Malformed response payload | UI | Safe fallback error handling |

## 8. Stretch Goal Tests
| ID | Scenario | Type | Expected Result |
|---|---|---|---|
| TM-34 | Rapid typing in search field | UI | Debounced requests, not one per keystroke |
| TM-35 | Pause typing 300ms | UI | Search executes after debounce delay |
| TM-36 | Match highlight rendering | UI | Correct substring highlighted |

## 9. Exit Gate
Release candidate can proceed only when:
1. All matrix cases pass.
2. No unresolved critical or high-severity defects.
3. Regression pass is clean after final integration.