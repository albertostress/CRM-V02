document.addEventListener('DOMContentLoaded', function () {
    // Replace Official Extensions with custom branding
    function replaceOfficialExtensions() {
        // Find the Official Extensions heading
        const headings = document.querySelectorAll('.panel-heading');
        headings.forEach(heading => {
            if (heading.textContent.includes('Official Extensions')) {
                // Replace the heading text
                heading.innerHTML = '<h4>EVERTEC Solutions</h4>';
                
                // Find and replace the panel body content
                const panelBody = heading.nextElementSibling;
                if (panelBody && panelBody.classList.contains('panel-body')) {
                    panelBody.innerHTML = `
                        <div style="padding: 20px; text-align: center;">
                            <h3 style="color: #333; margin-bottom: 15px;">EVERTEC CRM Platform</h3>
                            <p style="color: #666; margin-bottom: 20px;">
                                Enterprise CRM Solution powered by EVERTEC
                            </p>
                            <div style="margin: 20px 0;">
                                <a href="https://www.evertec.com" target="_blank" 
                                   style="background: #007bff; color: white; padding: 10px 20px; 
                                          text-decoration: none; border-radius: 5px; display: inline-block;">
                                    Visit EVERTEC Website
                                </a>
                            </div>
                            <div style="margin-top: 30px; padding-top: 20px; border-top: 1px solid #eee;">
                                <p style="color: #999; font-size: 12px;">
                                    © 2025 EVERTEC Corporation. All rights reserved.
                                </p>
                            </div>
                        </div>
                    `;
                }
            }
        });
    }
    
    // Run immediately and also after a delay (for dynamic content)
    replaceOfficialExtensions();
    setTimeout(replaceOfficialExtensions, 1000);
    setTimeout(replaceOfficialExtensions, 3000);
    
    // Also observe for changes in case content loads dynamically
    const observer = new MutationObserver(replaceOfficialExtensions);
    observer.observe(document.body, {
        childList: true,
        subtree: true
    });
});