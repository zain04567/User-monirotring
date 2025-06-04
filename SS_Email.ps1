<#
.SYNOPSIS
    Captures the entire primary screen as a PNG and emails it.

.DESCRIPTION
    1. Takes a screenshot of the primary monitor.
    2. Saves it to a temporary file (in $env:TEMP).
    3. Uses the Send-ToEmail function (configured for smtp.gmail.com:587) to send the screenshot to a specified recipient.

.NOTES
    - Make sure you have .NET assemblies System.Windows.Forms and System.Drawing available.
    - This script uses your existing SMTP credentials:
        $Username = "zain@adnare.com"
        $Password = "bufuywiwoskyhcla"
    - By default, it will send to "zain.ul.abideen1565@gmail.com". You can override via the -RecipientEmail parameter.

.EXAMPLE
    PS> .\Send-ScreenshotEmail.ps1
    (Captures screenshot, emails to the default address.)

.EXAMPLE
    PS> .\Send-ScreenshotEmail.ps1 -RecipientEmail "someone@example.com"
    (Captures screenshot, emails to someone@example.com.)
#>

param (
    [string]$RecipientEmail = "zain.ul.abideen1565@gmail.com"
)

# ---------------------------------------------------------
# 1) Configuration: SMTP credentials + screenshot filename
# ---------------------------------------------------------
# Your SMTP credentials (app password, etc.)
$Username = "zain@adnare.com"
$Password = "zxzxzxzxa"

# Temporary path for the screenshot (PNG)
$timestamp = (Get-Date).ToString("yyyyMMdd_HHmmss")
$screenshotPath = Join-Path $env:TEMP "screenshot_$timestamp.png"

# ---------------------------------------------------------
# 2) Function: Take a full‐screen screenshot & save to disk
# ---------------------------------------------------------
function Capture-Screenshot {
    param (
        [string]$OutputPath
    )

    # Load Windows.Forms and Drawing assemblies
    Add-Type -AssemblyName System.Windows.Forms
    Add-Type -AssemblyName System.Drawing

    # Determine primary screen dimensions
    $width  = [System.Windows.Forms.Screen]::PrimaryScreen.Bounds.Width
    $height = [System.Windows.Forms.Screen]::PrimaryScreen.Bounds.Height

    # Create a bitmap in memory
    $bitmap = New-Object System.Drawing.Bitmap($width, $height)

    # Create a Graphics object from that bitmap
    $graphics = [System.Drawing.Graphics]::FromImage($bitmap)

    # Copy from screen into our bitmap (top-left is 0,0)
    $graphics.CopyFromScreen(0, 0, 0, 0, $bitmap.Size)

    # Save as PNG
    $bitmap.Save($OutputPath, [System.Drawing.Imaging.ImageFormat]::Png)

    # Clean up
    $graphics.Dispose()
    $bitmap.Dispose()
}

# ---------------------------------------------------------
# 3) Function: Send an email with one attachment
# ---------------------------------------------------------
function Send-ToEmail {
    param (
        [string]$EmailTo,
        [string]$AttachmentPath
    )

    # Build the MailMessage object
    $message = New-Object Net.Mail.MailMessage
    $message.From = $Username
    $message.To.Add($EmailTo)
    $message.Subject = "Automated Screenshot - $timestamp"
    $message.Body = "Please find the attached screenshot taken on $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')."

    # Attach the PNG screenshot
    if (Test-Path $AttachmentPath) {
        $attachment = New-Object Net.Mail.Attachment($AttachmentPath)
        $message.Attachments.Add($attachment)
    }
    else {
        Write-Error "Attachment not found: $AttachmentPath"
        return
    }

    # Configure SMTP client for Gmail (port 587, SSL)
    $smtp = New-Object Net.Mail.SmtpClient("smtp.gmail.com", 587)
    $smtp.EnableSSL = $true
    $smtp.Credentials = New-Object System.Net.NetworkCredential($Username, $Password)

    # Send and dispose
    try {
        $smtp.Send($message)
        Write-Host "Mail sent to $EmailTo (with attachment)." -ForegroundColor Green
    }
    catch {
        Write-Error "Failed to send mail: $_"
    }
    finally {
        $attachment.Dispose()
        $message.Dispose()
        $smtp.Dispose()
    }
}

# ---------------------------------------------------------
# 4) Main: Capture + Send
# ---------------------------------------------------------
Write-Host "Capturing screenshot to: $screenshotPath"
Capture-Screenshot -OutputPath $screenshotPath

Write-Host "Sending email to: $RecipientEmail"
Send-ToEmail -EmailTo $RecipientEmail -AttachmentPath $screenshotPath

# Optionally, you can delete the screenshot file after sending:
# Remove-Item $screenshotPath -ErrorAction SilentlyContinue
