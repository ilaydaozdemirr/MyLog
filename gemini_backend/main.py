from fastapi import FastAPI, HTTPException
from fastapi.responses import JSONResponse
from fastapi.responses import Response
from pydantic import BaseModel
import requests
import json
import os
from dotenv import load_dotenv
from fastapi.middleware.cors import CORSMiddleware

load_dotenv()

app = FastAPI()

# Geliştirme aşamasında CORS açık
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

class PromptRequest(BaseModel):
    prompt: str

@app.post("/analyze")
def analyze_text(data: PromptRequest):
    url = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent"
    headers = {"Content-Type": "application/json"}
    payload = {
       "contents": [
        {
            "parts": [
                {
                    "text": f"""
Sen bir psikiyatristsin. Yazıyı analiz ederken Aaron T. Beck, Carl Jung ve Viktor Frankl gibi önemli terapistlerin yaklaşımını benimse.

Kullanıcı bir günlük yazısı paylaştı. Lütfen bu yazıyı klinik bir gözle değerlendir:

- Hangi temel duygular var? (örneğin: kaygı, çaresizlik, umut, motivasyon)
- Duyguların altında yatan olası nedenler nelerdir?
- Kullanıcının ruh hali hangi psikolojik yaklaşımla açıklanabilir?
- Hangi düşünce kalıpları veya bilişsel çarpıtmalar dikkat çekiyor?
- Yazıdan çıkarılabilecek psikolojik ihtiyaçlar neler?
- Bilimsel temellere dayalı, kişiye destek olabilecek kısa ama etkili öneriler ve minik “terapi yönlendirmeleri” ver.

Cevabın sıcak, empatik ama bilimsel olsun. Kullanıcının kendini anlaşılmış hissetmesini sağla. Gerektiğinde küçük metaforlar kullanarak anlatımı güçlendir.

Günlük yazısı:
\"\"\"{data.prompt}\"\"\"
"""
                }
            ]
        }
    ]
} 
    

    response = requests.post(
        url + f"?key={os.getenv('GEMINI_API_KEY')}",
        headers=headers,
        json=payload
    )

    response.encoding = 'utf-8'

    if response.status_code != 200:
        print("Gemini Error Response:", response.text)
        raise HTTPException(status_code=500, detail="Gemini API request failed.")

    try:
        result_text = response.json()["candidates"][0]["content"]["parts"][0]["text"]
        return Response(
            content=json.dumps({"response": result_text}, ensure_ascii=False),
            media_type="application/json"
        )
    except Exception as e:
        print("Parsing Error:", e)
        raise HTTPException(status_code=500, detail="Invalid Gemini API response.")
