<?php
/**
 * Email Configuration
 * Loads SMTP settings from environment variables
 */

class EmailConfig {
    public static $host = 'mail.opad.com.ua';
    public static $port = 587;
    public static $secure = false;
    public static $username = 'noreply@opad.com.ua';
    public static $password = 'your_password';
    public static $fromEmail = 'noreply@opad.com.ua';
    public static $fromName = 'OPAD - Одеська обласна профспілка авіадиспетчерів';

    public static function loadFromEnv() {
        self::$host = getenv('SMTP_HOST') ?: self::$host;
        self::$port = (int)(getenv('SMTP_PORT') ?: self::$port);
        self::$secure = getenv('SMTP_SECURE') === 'true';
        self::$username = getenv('SMTP_USER') ?: self::$username;
        self::$password = getenv('SMTP_PASSWORD') ?: self::$password;
        self::$fromEmail = getenv('SMTP_FROM_EMAIL') ?: self::$fromEmail;
        self::$fromName = getenv('SMTP_FROM_NAME') ?: self::$fromName;
    }
}

// Load from environment on include
EmailConfig::loadFromEnv();
?>
