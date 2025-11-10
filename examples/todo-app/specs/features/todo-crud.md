# Feature: Todo CRUD API

## Purpose
Provide RESTful API endpoints for creating, reading, updating, and deleting todo items.
Enables basic todo management functionality with validation and error handling.

## Requirements

### Functional Requirements

1. **List all todos**
   - Endpoint: `GET /api/todos`
   - Returns array of all todo items
   - Includes: id, title, description, completed, created_at, updated_at
   - Default sort: created_at descending (newest first)

2. **Create todo**
   - Endpoint: `POST /api/todos`
   - Accepts: title (required), description (optional), due_date (optional)
   - Validates input per constitution validation standards
   - Returns: created todo with 201 status
   - Sets: completed = false, created_at = now, updated_at = now

3. **Get single todo**
   - Endpoint: `GET /api/todos/:id`
   - Returns: todo object if exists
   - Returns: 404 if todo not found

4. **Update todo**
   - Endpoint: `PUT /api/todos/:id`
   - Accepts: title, description, completed, due_date (all optional)
   - Supports partial updates (only provided fields updated)
   - Updates: updated_at = now
   - Returns: updated todo object

5. **Delete todo**
   - Endpoint: `DELETE /api/todos/:id`
   - Removes todo from system
   - Returns: 204 No Content on success
   - Returns: 404 if todo not found

6. **Mark todo complete**
   - Endpoint: `PUT /api/todos/:id/complete`
   - Sets: completed = true, updated_at = now
   - Returns: updated todo object
   - Returns: 404 if todo not found

### Non-Functional Requirements

1. **Performance**
   - List endpoint: < 100ms for up to 1000 todos
   - Single todo operations: < 50ms
   - No N+1 query problems

2. **Data Integrity**
   - All database operations atomic
   - No orphaned records
   - Timestamps always accurate

3. **Scalability**
   - Support at least 10,000 todos per user
   - Efficient pagination for large lists

## Success Criteria

- [ ] All CRUD operations work correctly
- [ ] All validation rules enforced
- [ ] All error cases handled properly
- [ ] All endpoints return correct status codes
- [ ] Performance requirements met
- [ ] 100% test coverage for all endpoints

## Error Handling

### Validation Errors (422)

**Invalid title:**
```json
{
  "error": "Title must be between 1 and 200 characters",
  "field": "title",
  "code": "VALIDATION_ERROR"
}
```

**Invalid description:**
```json
{
  "error": "Description cannot exceed 2000 characters",
  "field": "description",
  "code": "VALIDATION_ERROR"
}
```

**Invalid due_date:**
```json
{
  "error": "Due date cannot be in the past",
  "field": "due_date",
  "code": "VALIDATION_ERROR"
}
```

### Not Found Errors (404)

**Todo not found:**
```json
{
  "error": "Todo not found",
  "code": "NOT_FOUND"
}
```

### Server Errors (500)

**Database error:**
```json
{
  "error": "An error occurred while processing your request",
  "code": "INTERNAL_ERROR"
}
```

## Edge Cases

### Empty Title
- **Scenario:** POST with empty string title
- **Expected:** 422 validation error

### Very Long Description
- **Scenario:** POST with 2001 character description
- **Expected:** 422 validation error

### Non-existent ID
- **Scenario:** GET /api/todos/non-existent-uuid
- **Expected:** 404 not found

### Update Non-existent Todo
- **Scenario:** PUT /api/todos/non-existent-uuid
- **Expected:** 404 not found

### Delete Non-existent Todo
- **Scenario:** DELETE /api/todos/non-existent-uuid
- **Expected:** 404 not found

### Partial Update with Invalid Data
- **Scenario:** PUT /api/todos/:id with title = "" (empty)
- **Expected:** 422 validation error

### Duplicate Complete
- **Scenario:** PUT /api/todos/:id/complete on already completed todo
- **Expected:** 200 OK (idempotent)

## Request/Response Examples

### Create Todo

**Request:**
```http
POST /api/todos
Content-Type: application/json

{
  "title": "Buy groceries",
  "description": "Milk, eggs, bread",
  "due_date": "2025-11-15T18:00:00Z"
}
```

**Response:**
```http
HTTP/1.1 201 Created
Content-Type: application/json

{
  "id": "550e8400-e29b-41d4-a716-446655440000",
  "title": "Buy groceries",
  "description": "Milk, eggs, bread",
  "completed": false,
  "due_date": "2025-11-15T18:00:00Z",
  "created_at": "2025-11-10T10:00:00Z",
  "updated_at": "2025-11-10T10:00:00Z"
}
```

### List Todos

**Request:**
```http
GET /api/todos
```

**Response:**
```http
HTTP/1.1 200 OK
Content-Type: application/json

[
  {
    "id": "550e8400-e29b-41d4-a716-446655440000",
    "title": "Buy groceries",
    "description": "Milk, eggs, bread",
    "completed": false,
    "due_date": "2025-11-15T18:00:00Z",
    "created_at": "2025-11-10T10:00:00Z",
    "updated_at": "2025-11-10T10:00:00Z"
  },
  {
    "id": "550e8400-e29b-41d4-a716-446655440001",
    "title": "Finish project",
    "description": "Complete the todo app",
    "completed": true,
    "due_date": null,
    "created_at": "2025-11-09T14:30:00Z",
    "updated_at": "2025-11-10T09:00:00Z"
  }
]
```

### Update Todo

**Request:**
```http
PUT /api/todos/550e8400-e29b-41d4-a716-446655440000
Content-Type: application/json

{
  "completed": true
}
```

**Response:**
```http
HTTP/1.1 200 OK
Content-Type: application/json

{
  "id": "550e8400-e29b-41d4-a716-446655440000",
  "title": "Buy groceries",
  "description": "Milk, eggs, bread",
  "completed": true,
  "due_date": "2025-11-15T18:00:00Z",
  "created_at": "2025-11-10T10:00:00Z",
  "updated_at": "2025-11-10T11:30:00Z"
}
```

## Dependencies

**Internal:**
- Validation middleware (per constitution)
- Database connection (PostgreSQL or similar)
- Error handling middleware

**External:**
- None (no third-party APIs required)

## Constraints

- No authentication required (future enhancement)
- No multi-user support (single user assumed)
- No undo/history (future enhancement)
- No attachments or rich text

## Out of Scope

- User authentication and authorization
- Todo sharing/collaboration
- Todo categories/tags
- Recurring todos
- Todo reminders/notifications
- Search and filtering (basic list only)

## Open Questions

- None (all requirements clear for MVP)

## Acceptance

- [ ] All functional requirements implemented
- [ ] All validation rules enforced
- [ ] All error cases handled
- [ ] All edge cases tested
- [ ] Performance requirements met
- [ ] Spec compliance verified
