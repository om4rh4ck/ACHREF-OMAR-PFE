#!/usr/bin/env python3
"""
Generate professional PDF security reports with auto-generated insights
"""

import json
import os
from datetime import datetime
from pathlib import Path
import re

try:
    from reportlab.lib import colors
    from reportlab.lib.pagesizes import letter, A4
    from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
    from reportlab.lib.units import inch
    from reportlab.platypus import SimpleDocTemplate, Paragraph, Spacer, Table, TableStyle, PageBreak, Image
    from reportlab.lib.enums import TA_CENTER, TA_LEFT, TA_RIGHT, TA_JUSTIFY
except ImportError:
    print("Installing reportlab...")
    os.system("pip install reportlab")
    from reportlab.lib import colors
    from reportlab.lib.pagesizes import letter, A4
    from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
    from reportlab.lib.units import inch
    from reportlab.platypus import SimpleDocTemplate, Paragraph, Spacer, Table, TableStyle, PageBreak

REPORTS_DIR = Path("reports/security")
ARCHIVE_DIR = REPORTS_DIR / "archive"
PDF_OUTPUT_DIR = REPORTS_DIR / "pdf"

ARCHIVE_DIR.mkdir(parents=True, exist_ok=True)
PDF_OUTPUT_DIR.mkdir(parents=True, exist_ok=True)


def parse_vulnerabilities(report_file):
    """Parse vulnerability counts from HTML/text reports"""
    try:
        with open(report_file, 'r', encoding='utf-8', errors='ignore') as f:
            content = f.read()
        
        critical = len(re.findall(r'CRITICAL|Critical|critical', content))
        high = len(re.findall(r'HIGH|High|high', content))
        medium = len(re.findall(r'MEDIUM|Medium|medium', content))
        low = len(re.findall(r'LOW|Low|low', content))
        
        return {'critical': critical, 'high': high, 'medium': medium, 'low': low}
    except:
        return {'critical': 0, 'high': 0, 'medium': 0, 'low': 0}


def generate_recommendation(service, scan_type, vulns):
    """Generate professional recommendations based on vulnerabilities"""
    recommendations = []
    
    total = sum(vulns.values())
    if total == 0:
        return f"✅ {service} ({scan_type}): No vulnerabilities detected. Continue monitoring."
    
    severity_text = []
    if vulns['critical'] > 0:
        severity_text.append(f"{vulns['critical']} CRITICAL")
    if vulns['high'] > 0:
        severity_text.append(f"{vulns['high']} HIGH")
    if vulns['medium'] > 0:
        severity_text.append(f"{vulns['medium']} MEDIUM")
    if vulns['low'] > 0:
        severity_text.append(f"{vulns['low']} LOW")
    
    severity_str = ", ".join(severity_text)
    
    if vulns['critical'] > 0:
        return f"🔴 {service} ({scan_type}): CRITICAL - Found {severity_str}. IMMEDIATE action required. Patch vulnerabilities before production deployment."
    elif vulns['high'] > 0:
        return f"🟠 {service} ({scan_type}): HIGH - Found {severity_str}. Schedule urgent remediation. Update dependencies and deploy patch."
    elif vulns['medium'] > 0:
        return f"🟡 {service} ({scan_type}): MEDIUM - Found {severity_str}. Plan remediation in next release cycle."
    else:
        return f"🟢 {service} ({scan_type}): LOW - Found {severity_str}. Monitor and address in regular maintenance."


def create_professional_pdf(scan_date=None):
    """Create professional security report PDF"""
    if scan_date is None:
        scan_date = datetime.now().strftime("%Y-%m-%d")
    
    pdf_filename = PDF_OUTPUT_DIR / f"VERMEG-Security-Report-{scan_date}.pdf"
    
    # Create PDF
    doc = SimpleDocTemplate(
        str(pdf_filename),
        pagesize=A4,
        rightMargin=0.5*inch,
        leftMargin=0.5*inch,
        topMargin=0.5*inch,
        bottomMargin=0.5*inch
    )
    
    # Styles
    styles = getSampleStyleSheet()
    title_style = ParagraphStyle(
        'CustomTitle',
        parent=styles['Heading1'],
        fontSize=24,
        textColor=colors.HexColor('#1a1a1a'),
        spaceAfter=6,
        alignment=TA_CENTER,
        fontName='Helvetica-Bold'
    )
    
    heading_style = ParagraphStyle(
        'CustomHeading',
        parent=styles['Heading2'],
        fontSize=14,
        textColor=colors.HexColor('#2c3e50'),
        spaceAfter=12,
        spaceBefore=12,
        fontName='Helvetica-Bold'
    )
    
    normal_style = ParagraphStyle(
        'CustomNormal',
        parent=styles['Normal'],
        fontSize=10,
        alignment=TA_JUSTIFY,
        spaceAfter=6
    )
    
    # Content
    story = []
    
    # Title
    story.append(Paragraph("VERMEG SIRH", title_style))
    story.append(Paragraph("Security Assessment Report", styles['Heading2']))
    story.append(Spacer(1, 0.2*inch))
    
    # Metadata
    meta_data = [
        ['Report Date:', scan_date],
        ['Generated:', datetime.now().strftime("%Y-%m-%d %H:%M:%S")],
        ['Classification:', 'Internal - Confidential']
    ]
    meta_table = Table(meta_data, colWidths=[2*inch, 4*inch])
    meta_table.setStyle(TableStyle([
        ('BACKGROUND', (0, 0), (0, -1), colors.HexColor('#ecf0f1')),
        ('TEXTCOLOR', (0, 0), (-1, -1), colors.black),
        ('ALIGN', (0, 0), (-1, -1), 'LEFT'),
        ('FONTNAME', (0, 0), (0, -1), 'Helvetica-Bold'),
        ('FONTSIZE', (0, 0), (-1, -1), 10),
        ('BOTTOMPADDING', (0, 0), (-1, -1), 8),
        ('GRID', (0, 0), (-1, -1), 1, colors.HexColor('#bdc3c7'))
    ]))
    story.append(meta_table)
    story.append(Spacer(1, 0.3*inch))
    
    # Executive Summary
    story.append(Paragraph("Executive Summary", heading_style))
    
    # Parse all reports
    total_vulns = {'critical': 0, 'high': 0, 'medium': 0, 'low': 0}
    owasp_results = {}
    trivy_results = {}
    
    # OWASP scans
    for service in ['employee-service', 'recruitment-service', 'approval-service', 'api-gateway']:
        report_file = REPORTS_DIR / f"dependency-check-{service}.html"
        if report_file.exists():
            vulns = parse_vulnerabilities(report_file)
            owasp_results[service] = vulns
            for key in total_vulns:
                total_vulns[key] += vulns[key]
    
    # Trivy scans
    for service in ['employee-service', 'recruitment-service', 'approval-service', 'api-gateway', 'frontend']:
        report_file = REPORTS_DIR / f"trivy-{service}.html"
        if report_file.exists():
            vulns = parse_vulnerabilities(report_file)
            trivy_results[service] = vulns
            for key in total_vulns:
                total_vulns[key] += vulns[key]
    
    # Summary text
    summary_text = f"""
    This report provides a comprehensive security assessment of the VERMEG SIRH platform, 
    including dependency scanning, container image analysis, and source code quality evaluation.
    <br/><br/>
    <b>Total Vulnerabilities Found:</b> {sum(total_vulns.values())}<br/>
    • <font color="red"><b>Critical:</b> {total_vulns['critical']}</font><br/>
    • <font color="orange"><b>High:</b> {total_vulns['high']}</font><br/>
    • <font color="goldenrod"><b>Medium:</b> {total_vulns['medium']}</font><br/>
    • <font color="green"><b>Low:</b> {total_vulns['low']}</font>
    """
    story.append(Paragraph(summary_text, normal_style))
    story.append(Spacer(1, 0.2*inch))
    
    # Detailed Findings
    story.append(Paragraph("Detailed Findings & Recommendations", heading_style))
    
    # OWASP Dependency-Check
    if owasp_results:
        story.append(Paragraph("1. OWASP Dependency-Check (Java Dependencies)", styles['Heading3']))
        for service, vulns in owasp_results.items():
            recommendation = generate_recommendation(service, "OWASP", vulns)
            story.append(Paragraph(recommendation, normal_style))
        story.append(Spacer(1, 0.1*inch))
    
    # Trivy
    if trivy_results:
        story.append(Paragraph("2. Trivy Image Scan (Docker Security)", styles['Heading3']))
        for service, vulns in trivy_results.items():
            recommendation = generate_recommendation(service, "Trivy", vulns)
            story.append(Paragraph(recommendation, normal_style))
        story.append(Spacer(1, 0.1*inch))
    
    # Compliance & Best Practices
    story.append(PageBreak())
    story.append(Paragraph("Compliance & Best Practices", heading_style))
    
    compliance_items = [
        "✅ Implement regular dependency updates (monthly)",
        "✅ Enable automated vulnerability scanning in CI/CD",
        "✅ Establish patch management policy (critical: 24h, high: 7 days)",
        "✅ Conduct security code review before production deploy",
        "✅ Monitor runtime security incidents with SIEM",
    ]
    
    for item in compliance_items:
        story.append(Paragraph(item, normal_style))
    
    story.append(Spacer(1, 0.2*inch))
    
    # Footer
    footer_text = f"""
    <b>Report Classification:</b> Internal - Confidential<br/>
    <b>Prepared by:</b> VERMEG Security Team<br/>
    <b>Contact:</b> security@vermeg.com
    """
    story.append(Paragraph(footer_text, normal_style))
    
    # Build PDF
    doc.build(story)
    print(f"✅ PDF Report generated: {pdf_filename}")
    
    return pdf_filename


def create_report_index():
    """Create HTML index of all archived reports"""
    archive_reports = sorted(ARCHIVE_DIR.glob("*.json"), reverse=True)[:30]  # Last 30 days
    
    html_content = """
    <!DOCTYPE html>
    <html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Security Report History</title>
        <style>
            body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; margin: 20px; background: #f5f5f5; }
            h1 { color: #2c3e50; }
            .report-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(250px, 1fr)); gap: 15px; }
            .report-card { 
                background: white; 
                border-radius: 8px; 
                padding: 15px; 
                box-shadow: 0 2px 8px rgba(0,0,0,0.1);
                transition: transform 0.2s;
            }
            .report-card:hover { transform: translateY(-2px); box-shadow: 0 4px 12px rgba(0,0,0,0.15); }
            .date { font-weight: bold; color: #3498db; }
            .critical { color: #c0392b; }
            .high { color: #e67e22; }
            .medium { color: #f39c12; }
            .low { color: #27ae60; }
            a { color: #3498db; text-decoration: none; }
            a:hover { text-decoration: underline; }
        </style>
    </head>
    <body>
        <h1>📊 Security Report History</h1>
        <div class="report-grid">
    """
    
    for report_file in archive_reports:
        try:
            with open(report_file, 'r') as f:
                data = json.load(f)
            
            html_content += f"""
            <div class="report-card">
                <div class="date">📅 {data.get('date', 'Unknown')}</div>
                <p>
                    <span class="critical">🔴 Critical: {data.get('critical', 0)}</span><br/>
                    <span class="high">🟠 High: {data.get('high', 0)}</span><br/>
                    <span class="medium">🟡 Medium: {data.get('medium', 0)}</span><br/>
                    <span class="low">🟢 Low: {data.get('low', 0)}</span>
                </p>
                <a href="pdf/VERMEG-Security-Report-{data.get('date', 'unknown')}.pdf" target="_blank">📄 Download PDF</a>
            </div>
            """
        except:
            pass
    
    html_content += """
        </div>
    </body>
    </html>
    """
    
    index_file = REPORTS_DIR / "history.html"
    with open(index_file, 'w') as f:
        f.write(html_content)
    
    print(f"✅ Report history index: {index_file}")


if __name__ == "__main__":
    print("🔍 Generating professional PDF security report...")
    
    # Generate PDF
    pdf_file = create_professional_pdf()
    
    # Archive report data
    scan_date = datetime.now().strftime("%Y-%m-%d")
    archive_file = ARCHIVE_DIR / f"report-{scan_date}.json"
    
    # Gather metrics
    total_vulns = {'critical': 0, 'high': 0, 'medium': 0, 'low': 0}
    for report_file in REPORTS_DIR.glob("*.html"):
        if 'trivy' in report_file.name or 'dependency-check' in report_file.name:
            vulns = parse_vulnerabilities(report_file)
            for key in total_vulns:
                total_vulns[key] += vulns[key]
    
    archive_data = {
        'date': scan_date,
        'timestamp': datetime.now().isoformat(),
        **total_vulns
    }
    
    with open(archive_file, 'w') as f:
        json.dump(archive_data, f, indent=2)
    
    # Create history index
    create_report_index()
    
    print("✅ Security report generation complete!")
