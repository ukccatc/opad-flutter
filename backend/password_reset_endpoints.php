<?php
/**
 * Password Reset Endpoints
 * Add these cases to api.php switch statement
 */

// Forgot Password - Generate Reset Token
case ($route === 'auth/forgot-password' && $method === 'POST'):
    $body = get_json_body();
    $email = isset($body['email']) ? trim($body['email']) : null;
    
    if (!$email) {
        http_response_code(400);
        echo json_encode(["error" => "Email is required"]);
        break;
    }
    
    // Validate email exists
    $stmt = $mysqli->prepare("SELECT Email, ФИО FROM Users WHERE Email = ? UNION SELECT Email, ФИО FROM Stats WHERE Email = ?");
    $stmt->bind_param("ss", $email, $email);
    $stmt->execute();
    $result = $stmt->get_result();
    
    if ($result->num_rows === 0) {
        // Don't reveal if email exists (security)
        echo json_encode(["success" => true, "message" => "If email exists, reset link will be sent"]);
        break;
    }
    
    $user = $result->fetch_assoc();
    $name = $user['ФИО'] ?? 'User';
    
    try {
        // Generate secure token
        $token = bin2hex(random_bytes(32));
        $expiry = date('Y-m-d H:i:s', strtotime('+24 hours'));
        
        // Create password_resets table if not exists
        $mysqli->query("CREATE TABLE IF NOT EXISTS password_resets (
            id INT AUTO_INCREMENT PRIMARY KEY,
            email VARCHAR(255) NOT NULL,
            token VARCHAR(255) NOT NULL UNIQUE,
            expiry DATETIME NOT NULL,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            INDEX idx_email (email),
            INDEX idx_token (token),
            INDEX idx_expiry (expiry)
        )");
        
        // Delete old tokens for this email
        $stmt = $mysqli->prepare("DELETE FROM password_resets WHERE email = ?");
        $stmt->bind_param("s", $email);
        $stmt->execute();
        
        // Store new token
        $stmt = $mysqli->prepare("INSERT INTO password_resets (email, token, expiry) VALUES (?, ?, ?)");
        $stmt->bind_param("sss", $email, $token, $expiry);
        $stmt->execute();
        
        // Generate reset link
        $resetLink = "https://opad.com.ua/reset?token=" . $token;
        
        // Send email
        if ($emailService) {
            $emailService->sendPasswordResetEmail($email, $name, $resetLink);
            Logger.info('📧 Password reset email sent to: ' . $email);
        }
        
        echo json_encode([
            "success" => true,
            "message" => "If email exists, reset link will be sent"
        ]);
    } catch (Exception $e) {
        http_response_code(500);
        echo json_encode(["error" => "Failed to process request: " . $e->getMessage()]);
    }
    break;

// Validate Reset Token
case ($route === 'auth/validate-token' && $method === 'POST'):
    $body = get_json_body();
    $token = isset($body['token']) ? trim($body['token']) : null;
    
    if (!$token) {
        http_response_code(400);
        echo json_encode(["error" => "Token is required"]);
        break;
    }
    
    try {
        // Check if token exists and is not expired
        $stmt = $mysqli->prepare("SELECT email FROM password_resets WHERE token = ? AND expiry > NOW()");
        $stmt->bind_param("s", $token);
        $stmt->execute();
        $result = $stmt->get_result();
        
        if ($result->num_rows === 0) {
            http_response_code(400);
            echo json_encode(["error" => "Invalid or expired token"]);
            break;
        }
        
        $row = $result->fetch_assoc();
        echo json_encode([
            "success" => true,
            "email" => $row['email'],
            "message" => "Token is valid"
        ]);
    } catch (Exception $e) {
        http_response_code(500);
        echo json_encode(["error" => "Failed to validate token: " . $e->getMessage()]);
    }
    break;

// Reset Password - Update Password with Token
case ($route === 'auth/reset-password' && $method === 'POST'):
    $body = get_json_body();
    $token = isset($body['token']) ? trim($body['token']) : null;
    $newPassword = isset($body['password']) ? $body['password'] : null;
    
    if (!$token || !$newPassword) {
        http_response_code(400);
        echo json_encode(["error" => "Token and password are required"]);
        break;
    }
    
    if (strlen($newPassword) < 6) {
        http_response_code(400);
        echo json_encode(["error" => "Password must be at least 6 characters"]);
        break;
    }
    
    try {
        // Validate token and get email
        $stmt = $mysqli->prepare("SELECT email FROM password_resets WHERE token = ? AND expiry > NOW()");
        $stmt->bind_param("s", $token);
        $stmt->execute();
        $result = $stmt->get_result();
        
        if ($result->num_rows === 0) {
            http_response_code(400);
            echo json_encode(["error" => "Invalid or expired token"]);
            break;
        }
        
        $row = $result->fetch_assoc();
        $email = $row['email'];
        
        // Hash password (same as WordPress)
        $passwordHash = md5('fsdfsd6287gf' . $newPassword);
        
        // Start transaction
        $mysqli->begin_transaction();
        
        try {
            // Update Users table
            $stmt = $mysqli->prepare("UPDATE Users SET Password = ? WHERE Email = ?");
            $stmt->bind_param("ss", $passwordHash, $email);
            $stmt->execute();
            
            // Update Stats table
            $stmt = $mysqli->prepare("UPDATE Stats SET Password = ? WHERE Email = ?");
            $stmt->bind_param("ss", $passwordHash, $email);
            $stmt->execute();
            
            // Delete used token
            $stmt = $mysqli->prepare("DELETE FROM password_resets WHERE token = ?");
            $stmt->bind_param("s", $token);
            $stmt->execute();
            
            $mysqli->commit();
            
            Logger.info('✅ Password reset successful for: ' . $email);
            
            echo json_encode([
                "success" => true,
                "message" => "Password has been reset successfully"
            ]);
        } catch (Exception $e) {
            $mysqli->rollback();
            throw $e;
        }
    } catch (Exception $e) {
        http_response_code(500);
        echo json_encode(["error" => "Failed to reset password: " . $e->getMessage()]);
    }
    break;

// Clean up expired tokens (optional - can be called periodically)
case ($route === 'auth/cleanup-tokens' && $method === 'POST'):
    try {
        $stmt = $mysqli->prepare("DELETE FROM password_resets WHERE expiry < NOW()");
        $stmt->execute();
        $deleted = $stmt->affected_rows;
        
        echo json_encode([
            "success" => true,
            "message" => "Cleaned up $deleted expired tokens"
        ]);
    } catch (Exception $e) {
        http_response_code(500);
        echo json_encode(["error" => "Failed to cleanup tokens: " . $e->getMessage()]);
    }
    break;

?>
