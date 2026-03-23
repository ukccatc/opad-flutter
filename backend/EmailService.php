<?php
/**
 * Email Service
 * Handles all email sending functionality
 */

require 'vendor/autoload.php';
require 'EmailConfig.php';

use PHPMailer\PHPMailer\PHPMailer;
use PHPMailer\PHPMailer\Exception;

class EmailService {
    private $mailer;

    public function __construct() {
        $this->mailer = new PHPMailer(true);
        $this->configureSMTP();
    }

    private function configureSMTP() {
        try {
            // SMTP configuration
            $this->mailer->isSMTP();
            $this->mailer->Host = EmailConfig::$host;
            $this->mailer->Port = EmailConfig::$port;
            $this->mailer->SMTPSecure = EmailConfig::$secure ? PHPMailer::ENCRYPTION_SMTPS : PHPMailer::ENCRYPTION_STARTTLS;
            $this->mailer->SMTPAuth = true;
            $this->mailer->Username = EmailConfig::$username;
            $this->mailer->Password = EmailConfig::$password;
            $this->mailer->CharSet = 'UTF-8';

            // From address
            $this->mailer->setFrom(EmailConfig::$fromEmail, EmailConfig::$fromName);
        } catch (Exception $e) {
            throw new Exception("SMTP Configuration Error: " . $e->getMessage());
        }
    }

    /**
     * Send password reset email
     */
    public function sendPasswordResetEmail($toEmail, $toName, $resetLink) {
        try {
            $this->mailer->addAddress($toEmail, $toName);
            $this->mailer->isHTML(true);
            $this->mailer->Subject = 'Скидання пароля - OPAD';

            $htmlBody = $this->getPasswordResetTemplate($toName, $resetLink);
            $this->mailer->Body = $htmlBody;
            $this->mailer->AltBody = strip_tags($htmlBody);

            $result = $this->mailer->send();
            $this->mailer->clearAddresses();
            return $result;
        } catch (Exception $e) {
            throw new Exception("Email Send Error: " . $e->getMessage());
        }
    }

    /**
     * Send welcome email
     */
    public function sendWelcomeEmail($toEmail, $toName) {
        try {
            $this->mailer->addAddress($toEmail, $toName);
            $this->mailer->isHTML(true);
            $this->mailer->Subject = 'Ласкаво просимо до OPAD';

            $htmlBody = $this->getWelcomeTemplate($toName);
            $this->mailer->Body = $htmlBody;
            $this->mailer->AltBody = strip_tags($htmlBody);

            $result = $this->mailer->send();
            $this->mailer->clearAddresses();
            return $result;
        } catch (Exception $e) {
            throw new Exception("Email Send Error: " . $e->getMessage());
        }
    }

    /**
     * Send notification email
     */
    public function sendNotificationEmail($toEmail, $toName, $subject, $message) {
        try {
            $this->mailer->addAddress($toEmail, $toName);
            $this->mailer->isHTML(true);
            $this->mailer->Subject = $subject;

            $htmlBody = $this->getNotificationTemplate($toName, $message);
            $this->mailer->Body = $htmlBody;
            $this->mailer->AltBody = strip_tags($htmlBody);

            $result = $this->mailer->send();
            $this->mailer->clearAddresses();
            return $result;
        } catch (Exception $e) {
            throw new Exception("Email Send Error: " . $e->getMessage());
        }
    }

    /**
     * Password reset email template
     */
    private function getPasswordResetTemplate($name, $resetLink) {
        return "
        <html>
        <head>
            <meta charset='UTF-8'>
            <style>
                body { font-family: Arial, sans-serif; color: #333; }
                .container { max-width: 600px; margin: 0 auto; padding: 20px; }
                .header { background-color: #0096D6; color: white; padding: 20px; text-align: center; border-radius: 5px; }
                .content { padding: 20px; background-color: #f9f9f9; margin-top: 20px; border-radius: 5px; }
                .button { display: inline-block; background-color: #0096D6; color: white; padding: 12px 30px; text-decoration: none; border-radius: 5px; margin: 20px 0; }
                .footer { text-align: center; color: #999; font-size: 12px; margin-top: 20px; }
            </style>
        </head>
        <body>
            <div class='container'>
                <div class='header'>
                    <h1>OPAD - Одеська обласна профспілка авіадиспетчерів</h1>
                </div>
                <div class='content'>
                    <p>Привіт, <strong>$name</strong>!</p>
                    <p>Ви запросили скидання пароля для вашого облікового запису.</p>
                    <p>Натисніть на кнопку нижче, щоб встановити новий пароль:</p>
                    <a href='$resetLink' class='button'>Скинути пароль</a>
                    <p>Це посилання дійсне протягом 24 годин.</p>
                    <p>Якщо ви не запросили скидання пароля, проігноруйте цей лист.</p>
                </div>
                <div class='footer'>
                    <p>© 2024 OPAD. Всі права захищені.</p>
                    <p>Це автоматичне повідомлення, будь ласка, не відповідайте на нього.</p>
                </div>
            </div>
        </body>
        </html>
        ";
    }

    /**
     * Welcome email template
     */
    private function getWelcomeTemplate($name) {
        return "
        <html>
        <head>
            <meta charset='UTF-8'>
            <style>
                body { font-family: Arial, sans-serif; color: #333; }
                .container { max-width: 600px; margin: 0 auto; padding: 20px; }
                .header { background-color: #0096D6; color: white; padding: 20px; text-align: center; border-radius: 5px; }
                .content { padding: 20px; background-color: #f9f9f9; margin-top: 20px; border-radius: 5px; }
                .footer { text-align: center; color: #999; font-size: 12px; margin-top: 20px; }
            </style>
        </head>
        <body>
            <div class='container'>
                <div class='header'>
                    <h1>OPAD - Одеська обласна профспілка авіадиспетчерів</h1>
                </div>
                <div class='content'>
                    <p>Ласкаво просимо, <strong>$name</strong>!</p>
                    <p>Ваш обліковий запис успішно створено.</p>
                    <p>Тепер ви можете отримувати доступ до всіх послуг OPAD.</p>
                </div>
                <div class='footer'>
                    <p>© 2024 OPAD. Всі права захищені.</p>
                </div>
            </div>
        </body>
        </html>
        ";
    }

    /**
     * Notification email template
     */
    private function getNotificationTemplate($name, $message) {
        return "
        <html>
        <head>
            <meta charset='UTF-8'>
            <style>
                body { font-family: Arial, sans-serif; color: #333; }
                .container { max-width: 600px; margin: 0 auto; padding: 20px; }
                .header { background-color: #0096D6; color: white; padding: 20px; text-align: center; border-radius: 5px; }
                .content { padding: 20px; background-color: #f9f9f9; margin-top: 20px; border-radius: 5px; }
                .footer { text-align: center; color: #999; font-size: 12px; margin-top: 20px; }
            </style>
        </head>
        <body>
            <div class='container'>
                <div class='header'>
                    <h1>OPAD - Одеська обласна профспілка авіадиспетчерів</h1>
                </div>
                <div class='content'>
                    <p>Привіт, <strong>$name</strong>!</p>
                    <p>$message</p>
                </div>
                <div class='footer'>
                    <p>© 2024 OPAD. Всі права захищені.</p>
                </div>
            </div>
        </body>
        </html>
        ";
    }
}
?>
