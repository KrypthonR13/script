from PIL import Image, ImageFilter
import pytesseract
import requests
from io import BytesIO

def download_image(url):
    """
    Mengunduh gambar dari URL.
    """
    try:
        response = requests.get(url)
        response.raise_for_status()  # Memeriksa apakah ada kesalahan saat mengunduh
        return Image.open(BytesIO(response.content))
    except Exception as e:
        print(f"Error saat mengunduh gambar: {e}")
        return None

def solve_captcha_from_url(url):
    """
    Mengunduh dan menyelesaikan CAPTCHA dari URL.
    """
    try:
        # Unduh gambar dari URL
        img = download_image(url)
        if img is None:
            return None
        
        # Preprocessing gambar
        img = img.convert("L")  # Konversi ke grayscale
        img = img.filter(ImageFilter.MedianFilter())  # Mengurangi noise
        
        # OCR untuk mengekstrak teks dari gambar
        captcha_text = pytesseract.image_to_string(img, config='--psm 8')
        
        return captcha_text.strip()
    except Exception as e:
        print(f"Error: {e}")
        return None

if __name__ == "__main__":
    # URL gambar CAPTCHA
    url = input("Masukkan URL gambar CAPTCHA: ").strip()
    
    # Selesaikan CAPTCHA
    result = solve_captcha_from_url(url)
    
    if result:
        print(f"CAPTCHA text: {result}")
    else:
        print("Gagal menyelesaikan CAPTCHA.")
