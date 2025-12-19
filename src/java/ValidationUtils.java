
import java.time.LocalDate;
import java.time.Period;
import java.time.format.DateTimeParseException;
import java.util.ArrayList;
import java.util.List;
import java.util.regex.Pattern;


public final class ValidationUtils {

    private static final Pattern EMAIL_PATTERN
            = Pattern.compile("^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+$");
    private static final Pattern USERNAME_PATTERN
            = Pattern.compile("^[A-Za-z0-9]{8,30}$");
    private static final Pattern PHONE_PATTERN
            = Pattern.compile("^\\d{9,13}$");

    private ValidationUtils() {
    }

    /**
     * Validates login inputs.
     */
    public static List<String> validateLogin(String email, String password) {
        List<String> errors = new ArrayList<>();

        if (isBlank(email)) {
            errors.add("Email is required.");
        } else if (!EMAIL_PATTERN.matcher(email).matches()) {
            errors.add("Enter a valid email address.");
        }

        if (isBlank(password)) {
            errors.add("Password is required.");
        } else if (password.length() < 8) {
            errors.add("Password must be at least 8 characters long.");
        }

        return errors;
    }

    /**
     * Validates signup inputs other than database constraints.
     */
    public static List<String> validateSignup(String username,
            String email,
            String password,
            String dateOfBirth,
            String phone) {
        List<String> errors = new ArrayList<>();

        if (isBlank(username)) {
            errors.add("Username is required.");
        } else if (!USERNAME_PATTERN.matcher(username).matches()) {
            errors.add("Username must be 8-30 characters and contain only letters and numbers.");
        }

        if (isBlank(email)) {
            errors.add("Email is required.");
        } else if (!EMAIL_PATTERN.matcher(email).matches()) {
            errors.add("Enter a valid email address.");
        }

        if (isBlank(password)) {
            errors.add("Password is required.");
        } else {
            validatePasswordStrength(password, errors);
        }

        validateDateOfBirth(dateOfBirth, errors);
        validatePhone(phone, errors);

        return errors;
    }

    private static void validatePasswordStrength(String password, List<String> errors) {
        if (password.length() < 10) {
            errors.add("Password must be at least 10 characters long.");
        }
        boolean hasUpper = false;
        boolean hasLower = false;
        boolean hasDigit = false;
        boolean hasSpecial = false;

        for (int i = 0; i < password.length(); i++) {
            char ch = password.charAt(i);
            if (Character.isUpperCase(ch)) {
                hasUpper = true;
            } else if (Character.isLowerCase(ch)) {
                hasLower = true;
            } else if (Character.isDigit(ch)) {
                hasDigit = true;
            } else {
                hasSpecial = true;
            }
        }

        if (!hasUpper) {
            errors.add("Password must include at least one uppercase letter.");
        }
        if (!hasLower) {
            errors.add("Password must include at least one lowercase letter.");
        }
        if (!hasDigit) {
            errors.add("Password must include at least one digit.");
        }
        if (!hasSpecial) {
            errors.add("Password must include at least one special character.");
        }
    }

    private static void validateDateOfBirth(String dob, List<String> errors) {
        if (isBlank(dob)) {
            errors.add("Date of birth is required.");
            return;
        }

        try {
            LocalDate birthDate = LocalDate.parse(dob);
            LocalDate today = LocalDate.now();
            if (birthDate.isAfter(today)) {
                errors.add("Date of birth cannot be in the future.");
                return;
            }

            int age = Period.between(birthDate, today).getYears();
            if (age < 13) {
                errors.add("You must be at least 13 years old to register.");
            }
        } catch (DateTimeParseException ex) {
            errors.add("Date of birth is invalid.");
        }
    }

    private static void validatePhone(String phone, List<String> errors) {
        if (isBlank(phone)) {
            errors.add("Phone number is required.");
        } else if (!PHONE_PATTERN.matcher(phone).matches()) {
            errors.add("Phone number must contain 9 to 13 digits only.");
        }
    }

    private static boolean isBlank(String value) {
        return value == null || value.trim().isEmpty();
    }
}
