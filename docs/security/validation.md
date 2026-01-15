# Input Validation Patterns

Comprehensive patterns for validating external input in Klar.

## The Validation Principle

> Never trust external input. Validate everything at system boundaries.

External input includes:
- User input (CLI, GUI, stdin)
- File contents
- Network data
- Environment variables
- Database results (if from untrusted sources)

## Pattern 1: Validation at Boundaries

Validate input as early as possible:

```klar
/// Entry point for HTTP requests
fn handle_request(raw_request: RawRequest) -> Response {
    // Validate immediately
    let request = ValidatedRequest.from_raw(raw_request) match {
        Ok(req) => req,
        Err(e) => return Response.bad_request(e.message())
    }

    // Rest of handler works with validated data
    process_request(request)
}
```

## Pattern 2: Validation Result Types

Use types to represent validation state:

```klar
/// Unvalidated user input
struct RawInput {
    value: string
}

/// Validated user input (guaranteed safe)
struct ValidatedInput {
    value: string
}

impl ValidatedInput {
    fn from_raw(raw: RawInput) -> Result[ValidatedInput, ValidationError] {
        validate_input(&raw.value)?
        Ok(ValidatedInput { value: raw.value })
    }

    fn value(self: &ValidatedInput) -> &string {
        &self.value
    }
}

// Functions that need validated input take ValidatedInput
fn process(input: ValidatedInput) { ... }
```

## Pattern 3: Comprehensive Validators

Build reusable validators:

```klar
struct StringValidator {
    min_length: ?usize
    max_length: ?usize
    pattern: ?Regex
    allowed_chars: ?string
    forbidden_chars: ?string
}

impl StringValidator {
    fn new() -> StringValidator {
        StringValidator {
            min_length: None,
            max_length: None,
            pattern: None,
            allowed_chars: None,
            forbidden_chars: None
        }
    }

    fn min_length(self: StringValidator, n: usize) -> StringValidator {
        StringValidator { min_length: Some(n), ..self }
    }

    fn max_length(self: StringValidator, n: usize) -> StringValidator {
        StringValidator { max_length: Some(n), ..self }
    }

    fn pattern(self: StringValidator, p: Regex) -> StringValidator {
        StringValidator { pattern: Some(p), ..self }
    }

    fn validate(self: &StringValidator, input: &string) -> Result[(), ValidationError] {
        if let Some(min) = self.min_length {
            if input.len() < min {
                return Err(ValidationError.TooShort { min: min, actual: input.len() })
            }
        }

        if let Some(max) = self.max_length {
            if input.len() > max {
                return Err(ValidationError.TooLong { max: max, actual: input.len() })
            }
        }

        if let Some(ref pattern) = self.pattern {
            if not pattern.is_match(input) {
                return Err(ValidationError.PatternMismatch)
            }
        }

        if let Some(ref allowed) = self.allowed_chars {
            for c in input.chars() {
                if not allowed.contains(c) {
                    return Err(ValidationError.ForbiddenChar(c))
                }
            }
        }

        if let Some(ref forbidden) = self.forbidden_chars {
            for c in input.chars() {
                if forbidden.contains(c) {
                    return Err(ValidationError.ForbiddenChar(c))
                }
            }
        }

        Ok(())
    }
}

// Usage
const USERNAME_VALIDATOR = StringValidator.new()
    .min_length(3)
    .max_length(32)
    .pattern(regex("[a-zA-Z][a-zA-Z0-9_]*"))

fn validate_username(input: &string) -> Result[(), ValidationError] {
    USERNAME_VALIDATOR.validate(input)
}
```

## Pattern 4: Numeric Validation

```klar
struct NumericValidator[T: Numeric] {
    min: ?T
    max: ?T
    allow_negative: bool
}

impl NumericValidator[T] {
    fn validate(self: &NumericValidator[T], value: T) -> Result[T, ValidationError] {
        if not self.allow_negative and value < T.zero() {
            return Err(ValidationError.NegativeNotAllowed)
        }

        if let Some(min) = self.min {
            if value < min {
                return Err(ValidationError.BelowMinimum { min: min, actual: value })
            }
        }

        if let Some(max) = self.max {
            if value > max {
                return Err(ValidationError.AboveMaximum { max: max, actual: value })
            }
        }

        Ok(value)
    }
}

// Usage
const AGE_VALIDATOR = NumericValidator[i32] {
    min: Some(0),
    max: Some(150),
    allow_negative: false
}

fn validate_age(age: i32) -> Result[i32, ValidationError] {
    AGE_VALIDATOR.validate(age)
}
```

## Pattern 5: Email Validation

```klar
struct Email {
    local: string
    domain: string
}

impl Email {
    fn parse(input: &string) -> Result[Email, EmailError] {
        // Length check
        if input.len() > 254 {
            return Err(EmailError.TooLong)
        }

        // Find @ symbol
        let at_pos = input.find('@') match {
            Some(pos) => pos,
            None => return Err(EmailError.MissingAt)
        }

        let local = &input[..at_pos]
        let domain = &input[at_pos + 1..]

        // Validate local part
        if local.is_empty() or local.len() > 64 {
            return Err(EmailError.InvalidLocalPart)
        }

        // Validate domain
        if domain.is_empty() or not is_valid_domain(domain) {
            return Err(EmailError.InvalidDomain)
        }

        Ok(Email {
            local: local.to_string(),
            domain: domain.to_string()
        })
    }

    fn to_string(self: &Email) -> string {
        "{self.local}@{self.domain}"
    }
}

fn is_valid_domain(domain: &string) -> bool {
    // Must contain at least one dot
    if not domain.contains('.') {
        return false
    }

    // Each label must be valid
    for label in domain.split('.') {
        if label.is_empty() or label.len() > 63 {
            return false
        }
        if not label.chars().all(fn(c) {
            c.is_alphanumeric() or c == '-'
        }) {
            return false
        }
        if label.starts_with('-') or label.ends_with('-') {
            return false
        }
    }

    true
}
```

## Pattern 6: Structured Data Validation

```klar
struct UserRegistration {
    username: string
    email: string
    password: string
    age: i32
}

struct ValidatedRegistration {
    username: Username
    email: Email
    password: Password
    age: i32
}

impl ValidatedRegistration {
    fn from_raw(raw: UserRegistration) -> Result[ValidatedRegistration, RegistrationError] {
        let mut errors = Vec.new()

        let username = Username.parse(&raw.username)
            .map_err(fn(e) { errors.push(FieldError.new("username", e)) });

        let email = Email.parse(&raw.email)
            .map_err(fn(e) { errors.push(FieldError.new("email", e)) });

        let password = Password.validate(&raw.password)
            .map_err(fn(e) { errors.push(FieldError.new("password", e)) });

        let age = validate_age(raw.age)
            .map_err(fn(e) { errors.push(FieldError.new("age", e)) });

        if not errors.is_empty() {
            return Err(RegistrationError.ValidationFailed(errors))
        }

        Ok(ValidatedRegistration {
            username: username.unwrap(),
            email: email.unwrap(),
            password: password.unwrap(),
            age: age.unwrap()
        })
    }
}
```

## Pattern 7: Sanitization

Sometimes you want to sanitize rather than reject:

```klar
/// Sanitizes a string for safe display in HTML
fn sanitize_html(input: &string) -> string {
    input
        .replace("&", "&amp;")
        .replace("<", "&lt;")
        .replace(">", "&gt;")
        .replace("\"", "&quot;")
        .replace("'", "&#x27;")
}

/// Sanitizes a filename by removing dangerous characters
fn sanitize_filename(input: &string) -> string {
    input
        .chars()
        .filter(fn(c) { c.is_alphanumeric() or c == '.' or c == '-' or c == '_' })
        .collect()
}

/// Truncates string to maximum length
fn truncate(input: &string, max_len: usize) -> string {
    if input.len() <= max_len {
        input.clone()
    } else {
        input[..max_len].to_string()
    }
}
```

## Pattern 8: Whitelist Validation

Prefer whitelists over blacklists:

```klar
// BAD: Blacklist (easy to miss dangerous input)
fn is_safe_char_blacklist(c: char) -> bool {
    c != '<' and c != '>' and c != '&'  // Missing many dangerous chars!
}

// GOOD: Whitelist (explicitly allow only safe chars)
fn is_safe_char_whitelist(c: char) -> bool {
    c.is_alphanumeric() or c == ' ' or c == '.' or c == ','
}

// GOOD: Enum whitelist
enum AllowedOperation {
    Read
    Write
    Delete
}

fn perform_operation(op: AllowedOperation, resource: &Resource) -> Result[(), Error] {
    // Only whitelisted operations can be performed
    op match {
        Read => resource.read(),
        Write => resource.write(),
        Delete => resource.delete()
    }
}
```

## Validation Error Messages

Provide helpful but not exploitable error messages:

```klar
enum ValidationError {
    TooShort { min: usize, actual: usize }
    TooLong { max: usize, actual: usize }
    InvalidFormat
    ForbiddenChar(char)
}

impl ValidationError {
    // User-facing message (safe to display)
    fn user_message(self: &ValidationError) -> string {
        self match {
            TooShort { min, .. } => "Must be at least {min} characters"
            TooLong { max, .. } => "Must be at most {max} characters"
            InvalidFormat => "Invalid format"
            ForbiddenChar(_) => "Contains invalid characters"
        }
    }

    // Internal message (for logging, includes details)
    fn internal_message(self: &ValidationError) -> string {
        self match {
            TooShort { min, actual } => "Too short: min={min}, actual={actual}"
            TooLong { max, actual } => "Too long: max={max}, actual={actual}"
            InvalidFormat => "Invalid format"
            ForbiddenChar(c) => "Forbidden char: {c:?}"
        }
    }
}
```

## Validation Checklist

- [ ] All external input validated before use
- [ ] Length limits enforced
- [ ] Type conversions checked (string to number, etc.)
- [ ] Character restrictions applied (whitelist preferred)
- [ ] Format validation for structured data (email, URL, etc.)
- [ ] Range validation for numeric values
- [ ] Error messages don't leak sensitive information
- [ ] Validation happens at system boundaries
