<%@page contentType="text/html" pageEncoding="UTF-8"%>

<%
    Long expiryMillis = (Long) session.getAttribute("codeExpiryTime");
    long secondsLeft = 300; // Default 5 minutes
    if (expiryMillis != null) {
        long now = System.currentTimeMillis();
        secondsLeft = (expiryMillis - now) / 1000;
        if (secondsLeft < 0) {
            secondsLeft = 0;
        }
    }
%>

<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8"/>
        <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
        <title>Verify Account - Oishop Food</title>
        <link rel="stylesheet" href="css/bootstrap.css" />
        <script src="js/bootstrap.bundle.js"></script>
        <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons/font/bootstrap-icons.css" />
        <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">
        <style>
            * {
                margin: 0;
                padding: 0;
                box-sizing: border-box;
            }

            body {
                background: linear-gradient(135deg, #FFE4C4 0%, #FFA07A 25%, #FF8C69 50%, #FFB347 75%, #FFDAB9 100%);
                background-size: 300% 300%;
                animation: gradientFlow 12s ease infinite;
                min-height: 100vh;
                display: flex;
                align-items: center;
                justify-content: center;
                flex-direction: column;
                font-family: 'Poppins', sans-serif;
                position: relative;
                overflow: hidden;
            }

            /* Floating particles animation */
            .particles {
                position: absolute;
                top: 0;
                left: 0;
                width: 100%;
                height: 100%;
                overflow: hidden;
                z-index: 1;
            }

            .particle {
                position: absolute;
                background: rgba(255, 255, 255, 0.1);
                border-radius: 50%;
                animation: float 6s ease-in-out infinite;
            }

            .particle:nth-child(1) { width: 80px; height: 80px; left: 10%; animation-delay: 0s; }
            .particle:nth-child(2) { width: 60px; height: 60px; left: 20%; animation-delay: 2s; }
            .particle:nth-child(3) { width: 100px; height: 100px; left: 35%; animation-delay: 4s; }
            .particle:nth-child(4) { width: 70px; height: 70px; left: 70%; animation-delay: 1s; }
            .particle:nth-child(5) { width: 90px; height: 90px; left: 80%; animation-delay: 3s; }

            /* Background logo text */
            .bg-logo-text {
                position: absolute;
                top: 50%;
                left: 50%;
                transform: translate(-50%, -50%);
                font-size: 8rem;
                font-weight: 700;
                color: rgba(255, 255, 255, 0.03);
                user-select: none;
                pointer-events: none;
                z-index: 1;
                animation: logoFloat 8s ease-in-out infinite;
                text-shadow: 0 0 20px rgba(255, 255, 255, 0.05);
            }

            /* Gradient flow animation */
            @keyframes gradientFlow {
                0% { background-position: 0% 50%; }
                50% { background-position: 100% 50%; }
                100% { background-position: 0% 50%; }
            }

            @keyframes float {
                0%, 100% { transform: translateY(0px) rotate(0deg); }
                33% { transform: translateY(-30px) rotate(120deg); }
                66% { transform: translateY(30px) rotate(240deg); }
            }

            @keyframes logoFloat {
                0%, 100% { transform: translate(-50%, -50%) scale(1); opacity: 0.03; }
                50% { transform: translate(-50%, -50%) scale(1.05); opacity: 0.05; }
            }

            /* Logo */
            .logo {
                position: absolute;
                top: 30px;
                left: 30px;
                height: 50px;
                animation: bounceIn 1s ease-out;
                z-index: 10;
                filter: drop-shadow(0 4px 8px rgba(0, 0, 0, 0.1));
            }

            /* Main content */
            h1, p, .verify-card {
                position: relative;
                z-index: 5;
            }

            h1 {
                margin-top: 40px;
                color: #fff;
                text-shadow: 0 4px 8px rgba(0, 0, 0, 0.2);
                animation: fadeInDown 1.2s ease-out;
                font-weight: 600;
            }

            p {
                color: #fff;
                text-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
                animation: fadeIn 1.4s ease-out;
                font-weight: 400;
            }

            /* Verify card */
            .verify-card {
                max-width: 500px;
                width: 100%;
                border-radius: 25px;
                background: rgba(255, 255, 255, 0.95);
                backdrop-filter: blur(10px);
                box-shadow: 0 20px 40px rgba(0, 0, 0, 0.1);
                animation: zoomIn 1s ease-out;
                margin-top: 30px;
                border: 1px solid rgba(255, 255, 255, 0.2);
                position: relative;
                overflow: hidden;
            }

            .verify-card::before {
                content: '';
                position: absolute;
                top: 0;
                left: 0;
                right: 0;
                height: 4px;
                background: linear-gradient(90deg, #FF8C69, #FF5722, #FF8C69);
                background-size: 200% 100%;
                animation: shimmer 2s linear infinite;
            }

            @keyframes shimmer {
                0% { background-position: -200% 0; }
                100% { background-position: 200% 0; }
            }

            .inner-card {
                border-radius: 20px;
                padding: 40px;
            }

            .verify-header {
                text-align: center;
                margin-bottom: 30px;
            }

            .verify-header h2 {
                font-size: 1.8rem;
                color: #FF8C69;
                margin-bottom: 10px;
                font-weight: 600;
            }

            .verify-header p {
                color: #666;
                font-size: 0.95rem;
                margin: 0;
                text-shadow: none;
            }

            .header-icon {
                font-size: 3rem;
                color: #FF8C69;
                margin-bottom: 15px;
                animation: pulse 2s ease-in-out infinite;
            }

            @keyframes pulse {
                0%, 100% { transform: scale(1); }
                50% { transform: scale(1.05); }
            }

            /* Countdown */
            .countdown {
                background: linear-gradient(135deg, #FFF8E1, #FFECB3);
                color: #FF8C69;
                font-weight: 600;
                padding: 15px;
                border-radius: 12px;
                text-align: center;
                margin-bottom: 20px;
                border: 2px solid #FFD180;
                font-size: 1.1rem;
                position: relative;
            }

            .countdown.expired {
                background: linear-gradient(135deg, #FFEBEE, #FFCDD2);
                color: #d32f2f;
                border-color: #ef9a9a;
                animation: shake 0.5s ease-in-out;
            }

            @keyframes shake {
                0%, 100% { transform: translateX(0); }
                25% { transform: translateX(-5px); }
                75% { transform: translateX(5px); }
            }

            /* Form control */
            .form-control {
                border: 2px solid #FFE4C4;
                border-radius: 12px;
                padding: 15px;
                font-size: 1.2rem;
                text-align: center;
                letter-spacing: 3px;
                font-weight: 600;
                margin-bottom: 20px;
                transition: all 0.3s ease;
                background: rgba(255, 248, 225, 0.8);
            }

            .form-control:focus {
                border-color: #FF8C69;
                box-shadow: 0 0 0 0.2rem rgba(255, 140, 105, 0.25);
                background: #fff;
                transform: translateY(-2px);
            }

            .form-control:disabled {
                background: #f5f5f5;
                color: #999;
                border-color: #ddd;
            }

            /* Buttons */
            .btn {
                padding: 15px 25px;
                border-radius: 12px;
                font-weight: 600;
                font-size: 1rem;
                border: none;
                transition: all 0.3s ease;
                position: relative;
                overflow: hidden;
            }

            .btn::before {
                content: '';
                position: absolute;
                top: 0;
                left: -100%;
                width: 100%;
                height: 100%;
                background: linear-gradient(90deg, transparent, rgba(255, 255, 255, 0.2), transparent);
                transition: left 0.5s;
            }

            .btn:hover::before {
                left: 100%;
            }

            .btn-verify {
                width: 100%;
                background: linear-gradient(135deg, #FF8C69, #FFA07A);
                color: white;
                margin-bottom: 15px;
                box-shadow: 0 4px 15px rgba(255, 140, 105, 0.3);
            }

            .btn-verify:hover {
                background: linear-gradient(135deg, #FF7F50, #FF8C69);
                transform: translateY(-3px);
                box-shadow: 0 8px 25px rgba(255, 140, 105, 0.4);
            }

            .btn-verify:disabled {
                background: #ccc;
                transform: none;
                box-shadow: none;
            }

            .btn-resend {
                width: 100%;
                background: linear-gradient(135deg, #2196f3, #1976d2);
                color: white;
                margin-bottom: 15px;
                display: none;
                box-shadow: 0 4px 15px rgba(33, 150, 243, 0.3);
            }

            .btn-resend:hover {
                background: linear-gradient(135deg, #1976d2, #1565c0);
                transform: translateY(-3px);
                box-shadow: 0 8px 25px rgba(33, 150, 243, 0.4);
            }

            .btn-back {
                width: 100%;
                background: linear-gradient(135deg, #FFB347, #FFA07A);
                color: white;
                box-shadow: 0 4px 15px rgba(255, 179, 71, 0.3);
            }

            .btn-back:hover {
                background: linear-gradient(135deg, #FF9500, #FFB347);
                transform: translateY(-3px);
                box-shadow: 0 8px 25px rgba(255, 179, 71, 0.4);
            }

            /* Error message */
            .error-message {
                background: linear-gradient(135deg, #FF6B6B, #FF8E53);
                color: #fff;
                padding: 15px;
                border-radius: 12px;
                margin-bottom: 20px;
                font-size: 0.9rem;
                animation: slideInLeft 0.5s ease-out;
                box-shadow: 0 4px 15px rgba(0, 0, 0, 0.1);
            }

            @keyframes slideInLeft {
                from {
                    opacity: 0;
                    transform: translateX(-20px);
                }
                to {
                    opacity: 1;
                    transform: translateX(0);
                }
            }

            /* Success message */
            .alert-success {
                background: linear-gradient(135deg, #4ECDC4, #44A08D);
                color: #fff;
                border: none;
                border-radius: 12px;
                box-shadow: 0 4px 15px rgba(0, 0, 0, 0.1);
            }

            /* Divider */
            .divider {
                position: relative;
                text-align: center;
                margin: 20px 0;
            }

            .divider::before {
                content: '';
                position: absolute;
                top: 50%;
                left: 0;
                right: 0;
                height: 1px;
                background: linear-gradient(90deg, transparent, #FFB347, transparent);
            }

            .divider span {
                background: #fff;
                padding: 0 20px;
                color: #FF8C69;
                font-weight: 500;
            }

            /* Loading spinner */
            .loading-spinner {
                display: none;
                width: 20px;
                height: 20px;
                border: 2px solid #ffffff30;
                border-top: 2px solid #ffffff;
                border-radius: 50%;
                animation: spin 1s linear infinite;
                margin-right: 10px;
            }

            @keyframes spin {
                0% { transform: rotate(0deg); }
                100% { transform: rotate(360deg); }
            }

            /* Success animation */
            .success-checkmark {
                display: none;
                width: 80px;
                height: 80px;
                border-radius: 50%;
                background: #4caf50;
                margin: 20px auto;
                position: relative;
            }

            .success-checkmark::after {
                content: '';
                position: absolute;
                top: 50%;
                left: 50%;
                width: 25px;
                height: 15px;
                border: solid white;
                border-width: 0 0 3px 3px;
                transform: translate(-50%, -60%) rotate(-45deg);
            }

            /* Animations */
            @keyframes fadeIn {
                from { opacity: 0; }
                to { opacity: 1; }
            }

            @keyframes fadeInDown {
                from { opacity: 0; transform: translateY(-30px); }
                to { opacity: 1; transform: translateY(0); }
            }

            @keyframes zoomIn {
                from { opacity: 0; transform: scale(0.8); }
                to { opacity: 1; transform: scale(1); }
            }

            @keyframes bounceIn {
                0% { opacity: 0; transform: scale(0.3); }
                50% { opacity: 1; transform: scale(1.05); }
                70% { transform: scale(0.9); }
                100% { transform: scale(1); }
            }

            @keyframes slideInUp {
                from { opacity: 0; transform: translateY(30px); }
                to { opacity: 1; transform: translateY(0); }
            }

            /* Responsive */
            @media (max-width: 768px) {
                .bg-logo-text {
                    font-size: 4rem;
                }
                
                .verify-card {
                    margin: 20px;
                }
                
                .inner-card {
                    padding: 30px 20px;
                }
                
                .logo {
                    top: 20px;
                    left: 20px;
                    height: 40px;
                }
                
                h1 {
                    font-size: 2rem;
                    margin-top: 30px;
                }
            }

            @media (max-width: 576px) {
                .bg-logo-text {
                    font-size: 3rem;
                }
                
                .inner-card {
                    padding: 20px 15px;
                }
            }
        </style>
    </head>
    <body>
        <!-- Floating particles -->
        <div class="particles">
            <div class="particle"></div>
            <div class="particle"></div>
            <div class="particle"></div>
            <div class="particle"></div>
            <div class="particle"></div>
        </div>

        <!-- Background logo text -->
        <div class="bg-logo-text">OISHOP FOOD</div>

        <a href="/OishipFoodOrdering">
            <img src="images/logov2.png" alt="Oishop Logo" class="logo" />
        </a>

        <h1 class="display-4 fw-bold">Email Verification</h1>
        <p class="mt-3 fs-5">We've sent a 6-digit code to your email address</p>

        <div class="verify-card">
            <div class="inner-card">
                <div class="verify-header">
                    <i class="bi bi-shield-check header-icon"></i>
                    <h2>Verify Your Account</h2>
                    <p>Enter the verification code sent to your email</p>
                </div>

                <% if (request.getAttribute("error") != null) {%>
                <div class="error-message">
                    <i class="bi bi-exclamation-triangle me-2"></i>
                    <%= request.getAttribute("error")%>
                </div>
                <% }%>

                <form action="verify" method="POST" id="verifyForm">
                    <input type="text" name="code" class="form-control" id="codeInput"
                           placeholder="000000"
                           required maxlength="6" pattern="[0-9]{6}" inputmode="numeric"
                           title="Please enter a 6-digit code"/>

                    <div class="countdown" id="countdown">Code expires in: 05:00</div>

                    <button type="submit" class="btn btn-verify" id="verifyButton">
                        <span class="loading-spinner" id="loadingSpinner"></span>
                        <i class="bi bi-check-circle me-2"></i>
                        <span id="verifyText">Verify Code</span>
                    </button>

                    <button type="button" class="btn btn-resend" id="resendButton">
                        <i class="bi bi-arrow-repeat me-2"></i>
                        <span id="resendText">Resend Code</span>
                    </button>

                    <div class="divider">
                        <span><i class="bi bi-three-dots"></i></span>
                    </div>

                    <a href="/OishipFoodOrdering/register" class="btn btn-back">
                        <i class="bi bi-arrow-left me-2"></i>
                        Back to Registration
                    </a>
                </form>

                <div class="success-checkmark" id="successCheckmark"></div>
            </div>
        </div>

        <script>
            const countdownEl = document.getElementById('countdown');
            const resendButton = document.getElementById('resendButton');
            const verifyButton = document.getElementById('verifyButton');
            const codeInput = document.getElementById('codeInput');
            const loadingSpinner = document.getElementById('loadingSpinner');
            const verifyText = document.getElementById('verifyText');
            const resendText = document.getElementById('resendText');
            let timeLeft = <%= secondsLeft%>;

            const pad = (num) => num.toString().padStart(2, '0');
            const tpl = (m, s) => "Code expires in: " + pad(m) + ":" + pad(s);

            const updateCountdown = () => {
                if (timeLeft <= 0) {
                    countdownEl.textContent = "Code expired!";
                    countdownEl.classList.add('expired');
                    verifyButton.disabled = true;
                    codeInput.disabled = true;
                    resendButton.style.display = 'block';
                    clearInterval(timer);
                    return;
                }
                const minutes = Math.floor(timeLeft / 60);
                const seconds = timeLeft % 60;
                countdownEl.textContent = tpl(minutes, seconds);
                timeLeft--;
            };

            let timer = setInterval(updateCountdown, 1000);
            updateCountdown();

            // Form submit animation
            document.getElementById('verifyForm').addEventListener('submit', function(e) {
                loadingSpinner.style.display = 'inline-block';
                verifyText.textContent = 'Verifying...';
                verifyButton.disabled = true;
            });

            // Auto-format input
            codeInput.addEventListener('input', function(e) {
                let value = e.target.value.replace(/\D/g, '');
                e.target.value = value;
                
                if (value.length === 6) {
                    e.target.style.borderColor = '#4caf50';
                } else {
                    e.target.style.borderColor = '#FFE4C4';
                }
            });

            // Resend code functionality
            resendButton.addEventListener('click', function () {
                resendText.textContent = 'Sending...';
                resendButton.disabled = true;

                fetch('resend', {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/x-www-form-urlencoded',
                    }
                })
                .then(response => {
                    if (!response.ok) {
                        throw new Error('Network response was not ok');
                    }
                    return response.json();
                })
                .then(data => {
                    if (data.success) {
                        // Show success message
                        const successMsg = document.createElement('div');
                        successMsg.className = 'alert alert-success';
                        successMsg.innerHTML = '<i class="bi bi-check-circle me-2"></i>New verification code sent successfully!';
                        successMsg.style.animation = 'slideInLeft 0.5s ease-out';
                        document.querySelector('.inner-card').insertBefore(successMsg, document.querySelector('form'));
                        
                        setTimeout(() => successMsg.remove(), 3000);

                        // Reset timer to 5 minutes
                        timeLeft = 300;
                        countdownEl.textContent = tpl(5, 0);
                        countdownEl.classList.remove('expired');
                        verifyButton.disabled = false;
                        codeInput.disabled = false;
                        codeInput.value = "";
                        codeInput.focus();

                        // Hide resend button and reset
                        resendButton.style.display = 'none';
                        resendButton.disabled = false;
                        resendText.textContent = 'Resend Code';

                        // Restart countdown
                        clearInterval(timer);
                        timer = setInterval(updateCountdown, 1000);
                    } else {
                        // Show error message
                        const errorMsg = document.createElement('div');
                        errorMsg.className = 'error-message';
                        errorMsg.innerHTML = '<i class="bi bi-exclamation-triangle me-2"></i>' + (data.error || data.message || "Unknown error");
                        document.querySelector('.inner-card').insertBefore(errorMsg, document.querySelector('form'));
                        
                        setTimeout(() => errorMsg.remove(), 3000);
                        
                        resendButton.disabled = false;
                        resendText.textContent = 'Resend Code';
                    }
                })
                .catch(err => {
                    // Show error message
                    const errorMsg = document.createElement('div');
                    errorMsg.className = 'error-message';
                    errorMsg.innerHTML = '<i class="bi bi-exclamation-triangle me-2"></i>Request failed. Please try again.';
                    document.querySelector('.inner-card').insertBefore(errorMsg, document.querySelector('form'));
                    
                    setTimeout(() => errorMsg.remove(), 3000);
                    
                    console.error(err);
                    resendButton.disabled = false;
                    resendText.textContent = 'Resend Code';
                });
            });

            // Enhanced button hover effects
            document.querySelectorAll('.btn').forEach(btn => {
                btn.addEventListener('mouseenter', function() {
                    if (!this.disabled) {
                        this.style.transform = 'translateY(-2px)';
                    }
                });
                
                btn.addEventListener('mouseleave', function() {
                    if (!this.disabled) {
                        this.style.transform = 'translateY(0)';
                    }
                });
            });

            // Input focus effect
            codeInput.addEventListener('focus', function() {
                this.style.transform = 'scale(1.02)';
            });

            codeInput.addEventListener('blur', function() {
                this.style.transform = 'scale(1)';
            });
        </script>
    </body>
</html>