from fpdf import FPDF
from PIL import Image

# Create a PDF document
pdf = FPDF()
pdf.set_auto_page_break(auto=True, margin=15)

# Title Page
pdf.add_page()
pdf.set_font("Arial", 'B', 16)
pdf.cell(0, 10, "hosting-101.com AWS Altyapı Raporu", ln=True, align="C")

# Section 1: MİMARİ AÇIKLAMASI
section1 = """
1. AWS MİMARİ AÇIKLAMASI

Bu belge, hosting-101.com isimli yüksek trafikli WordPress sitesinin AWS üzerinde yüksek erişilebilirlik, güvenlik ve performans hedefleri doğrultusunda yapılandırılmasını içermektedir.

Temel bileşenler:
- Route 53
- CloudFront
- WAF & Shield
- Elastic Load Balancer
- EC2 (Auto Scaling ile)
- Amazon RDS (MariaDB)
- Amazon ElastiCache (Memcached)
- Amazon S3
- Internet Gateway, NAT Gateway
- VPC + Subnet mimarisi
"""

pdf.add_page()
pdf.set_font("Arial", size=12)
for line in section1.strip().split('\n'):
    pdf.multi_cell(0, 10, line)

# Add Architecture Diagram
pdf.add_page()
pdf.set_font("Arial", 'B', 14)
pdf.cell(0, 10, "Genel AWS Mimarisi", ln=True)
pdf.image("C:\Users\atunc\Downloads\ChatGPT Image 19 May 2025 22_29_23.png", x=10, w=190)

# Section 2: MALİYET HESAPLAMASI
section2 = """
2. AWS MALİYET HESAPLAMASI (Aylık)

| Hizmet             | Aylık Maliyet (USD) |
|--------------------|---------------------|
| EC2                | $60.74              |
| RDS                | $30.37              |
| ElastiCache        | $23.36              |
| S3                 | $0.69               |
| CloudFront         | $8.50               |
| Route 53           | $0.50               |
| NAT Gateway        | $32.85              |
| TOPLAM             | $157.01             |
"""

pdf.add_page()
pdf.set_font("Arial", size=12)
for line in section2.strip().split('\n'):
    pdf.multi_cell(0, 10, line)

# Section 3: VPC VE SUBNET DETAYLARI
section3 = """
3. VPC VE SUBNET DETAYLARI

CIDR Bloğu: 10.0.0.0/16

Subnet Planı:
- Public Subnet 1 (AZ A): 10.0.0.0/24
- Public Subnet 2 (AZ B): 10.0.1.0/24
- Private Subnet 1 (AZ A): 10.0.2.0/24
- Private Subnet 2 (AZ B): 10.0.3.0/24
- DB Subnet 1 (AZ A): 10.0.4.0/24
- DB Subnet 2 (AZ B): 10.0.5.0/24
- Cache Subnet: 10.0.6.0/24
"""

pdf.add_page()
pdf.set_font("Arial", size=12)
for line in section3.strip().split('\n'):
    pdf.multi_cell(0, 10, line)

# Add Network Diagram
pdf.add_page()
pdf.set_font("Arial", 'B', 14)
pdf.cell(0, 10, "VPC ve Subnet Ağı Şeması", ln=True)
pdf.image("/mnt/data/A_diagram_in_the_image_illustrates_a_Virtual_Priva.png", x=10, w=190)

# Save PDF
output_path = "/mnt/data/hosting101_aws_raporu.pdf"
pdf.output(output_path)
