from pymongo import MongoClient, TEXT
from deepface import DeepFace
from deepface.commons import functions,realtime,distance as dst
from tqdm import tqdm
import pandas as pd
import numpy as np
import os
import sys

connection = "mongodb+srv://akshar:akshar2103@cluster0.tcm3i.mongodb.net/faces?retryWrites=true&w=majority"
client = MongoClient(connection)
database = 'faces'
collection = 'users'
db = client[database]

img1_path = sys.argv[1]
img1_emb = DeepFace.represent(img1_path,model_name='Facenet')
img1_emb_arr = np.array(img1_emb)

mini=100
user_results = list(db.users.find({}))
for user in user_results:
    img2_emb = user['embedding']
    img2_emb_arr = np.array(img2_emb)
    distance = dst.findEuclideanDistance(dst.l2_normalize(img1_emb_arr), dst.l2_normalize(img2_emb_arr))
    distance = np.float64(distance)
    if distance<mini:
        mini=distance
        userID = user['_id']
        userName = user['name']

print(userID+userName)