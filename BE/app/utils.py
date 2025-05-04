
import requests

from passlib.context import CryptContext
from jose import jwt
from datetime import datetime, timedelta
from collections import Counter
from typing import List, Dict
import google.generativeai as genai
import re
import json



SECRET_KEY = "hackUPC2025"
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = 60
GEMNI_API_KEY = "AIzaSyCZMZmGwCYULYbMgjZcbp6OseC_33jU6cI"

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

def hash_password(password: str):
    return pwd_context.hash(password)

def verify_password(plain_password, hashed_password):
    return pwd_context.verify(plain_password, hashed_password)

def create_access_token(data: dict):
    to_encode = data.copy()
    expire = datetime.utcnow() + timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    to_encode.update({"exp": expire})
    return jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)


# app/utils.py
def aggregate_preferences(preferences_list: list[dict]) -> dict:
    interests = []
    weather = []
    months = []
    budget = []

    for pref in preferences_list:
        interests += pref.get("interests", [])
        weather.append(pref.get("weather"))
        months.append(pref.get("travel_month"))
        budget.append(pref.get("budget"))

    return {
        "origin": "TLV",  # or dynamically determine later
        "travel_month": max(set(months), key=months.count),  # most common month
        "budget": sum([int(b) for b in budget]) // len(budget) if budget else 500,
        "interests": list(set(interests)),
        "weather": max(set(weather), key=weather.count) if weather else "warm"
    }


# Load your Gemini API key from env
genai.configure(api_key=GEMNI_API_KEY)

model = genai.GenerativeModel(model_name="gemini-1.5-pro")


def extract_json_from_gemini(text: str) -> list[dict]:
    try:
        # Remove Markdown triple backticks and extract content inside
        json_match = re.search(r"```json\n(.*?)\n```", text, re.DOTALL)
        if not json_match:
            raise ValueError("No valid JSON found in Gemini response")

        json_str = json_match.group(1)
        return json.loads(json_str)
    except Exception as e:
        print("JSON extraction error:", str(e))
        return []

def fix_skyscanner_urls(destinations: list[dict], origin: str, outbound_date: str, inbound_date: str) -> list[dict]:
    """
    Replaces city names in the skyscanner_url with proper IATA codes.
    Dates must be in YYMMDD format.
    """
    for dest in destinations:
        iata = dest.get("iata_code",  "").lower()
        dest["skyscanner_url"] = (
            f"https://www.skyscanner.com/transport/flights/"
            f"{origin.lower()}/{iata}/{outbound_date}/{inbound_date}/"
            f"?adultsv2=1&cabinclass=economy&childrenv2=&ref=home&rtn=1&preferdirects=false"
            f"&outboundaltsenabled=false&inboundaltsenabled=false"
        )
    return destinations


def get_skyscanner_price(origin: str, destination: str, depart_date: str) -> int:
    """
    Gets the cheapest estimated round-trip flight price from Skyscanner Browse Quotes API.
    - `depart_date`: must be in 'YYYY-MM-DD' format
    """
    url = f"https://skyscanner-skyscanner-flight-search-v1.p.rapidapi.com/apiservices/browsequotes/v1.0/US/USD/en-US/{origin}/{destination}/{depart_date}"

    headers = {
        "X-RapidAPI-Key": "b95476bd7emsh93adc0f4c3d3835p1cd2e7jsn4ae3a7d62480",  # ← replace with your real key
        "X-RapidAPI-Host": "skyscanner-skyscanner-flight-search-v1.p.rapidapi.com"
    }

    try:
        response = requests.get(url, headers=headers)
        print(f"response->{response}")
        data = response.json()

        if "Quotes" in data and data["Quotes"]:
            return data["Quotes"][0]["MinPrice"]
        else:
            return -1  # No price found

    except Exception as e:
        print("Skyscanner API error:", str(e))
        return -1


def format_skyscanner_url(origin: str, destination: str, travel_month: str) -> str:
    try:
        year, month = travel_month.split("-")
        depart_date = f"{year[2:]}{month}01"
        return_date = f"{year[2:]}{month}31"
    except Exception:
        depart_date, return_date = "250701", "250731"  # fallback
    return (
        f"https://www.skyscanner.com/transport/flights/"
        f"{origin.lower()}/{destination.lower()}/{depart_date}/{return_date}/"
        f"?adultsv2=1&cabinclass=economy&childrenv2=&ref=home&rtn=1"
        f"&preferdirects=false&outboundaltsenabled=false&inboundaltsenabled=false"
    )

def suggest_destinations_with_gemini(preferences: dict) -> list[dict]:
    prompt = f"""
             I have a group of travelers with the following preferences:
            
            - Departure Airport: {preferences['origin']}
            - Preferred Travel Month: {preferences['travel_month']}
            - Budget per person: ${preferences['budget']}
            - Interests: {', '.join(preferences['interests'])}
            - Preferred Weather: {preferences['weather']}
            
            Based on this, suggest 5 ideal travel destinations.
            
            For each destination, include:
            - City Name
            - Country
            - IATA Airport Code (e.g., GVA for Geneva, ZRH for Zurich)
            - Reason why it fits their preferences
            - Approximate round-trip flight price from {preferences['origin']}
            - A **direct Picsum image URL** in the form `https://picsum.photos/seed/'city'/800/600`
            - A "**Skyscanner flight search URL** in this exact format:\nhttps://www.skyscanner.com/transport/flights/'origin_code'/'destination IATA Airport Code'/'depart_date'/'return_date'/?adultsv2=1&cabinclass=economy&childrenv2=&ref=home&rtn=1&preferdirects=false&outboundaltsenabled=false&inboundaltsenabled=false\nUse these exact placeholder variables for dynamic parts"
            - skyscanner_url (⚠️ Must use IATA code, not city name, and dates in format YYMMDD like /250801/250831/)

            
            ⚠️ Return only a JSON array using this exact format:
            ```json
            [
              {{
                "city": "Barcelona",
                "country": "Spain",
                "iata_code": "BCN",
                "reason": "Warm weather, beach and nightlife",
                "estimated_price": 520,
                "image_url": "https://example.com/image.jpg",
                "skyscanner_url": "https://www.skyscanner.com/transport/flights/from/to"
              }},
              ...
            ]
    """

    try:
        response = model.generate_content(prompt)
        suggestions = extract_json_from_gemini(response.text)

        # Extract travel month as dates
        year, month = preferences["travel_month"].split("-")
        outbound = f"{year}-{month}-01"
        inbound_yy = year[2:]
        outbound_fmt = f"{inbound_yy}{month}01"
        inbound_fmt = f"{inbound_yy}{month}31"
        full_depart_date = f"{year}-{month}-01"

        # Add real prices and build correct Skyscanner URLs
        for s in suggestions:
            iata = s.get("iata_code", "").upper()

            # Estimate price from Skyscanner API
            s["gemini_price"] = s.get("estimated_price", -1)

            # Format valid Skyscanner URL with IATA codes and YYMMDD dates
            s["skyscanner_url"] = (
                f"https://www.skyscanner.com/transport/flights/"
                f"{preferences['origin'].lower()}/{iata.lower()}/{outbound_fmt}/{inbound_fmt}/"
                f"?adultsv2=1&cabinclass=economy&childrenv2=&ref=home&rtn=1"
                f"&preferdirects=false&outboundaltsenabled=false&inboundaltsenabled=false"
            )

        return suggestions

    except Exception as e:
        print("Gemini API Error:", str(e))
        return []
