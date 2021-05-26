from pymongo import MongoClient, TEXT
from deepface import DeepFace
from deepface.commons import functions,realtime,distance as dst
import numpy as np

connection = "mongodb+srv://akshar:akshar2103@cluster0.tcm3i.mongodb.net/faces?retryWrites=true&w=majority"
client = MongoClient(connection)
database = 'faces'
db = client[database]

def findEuclideanDistance(source_representation, test_representation):
    if type(source_representation) == list:
        source_representation = np.array(source_representation)

    if type(test_representation) == list:
        test_representation = np.array(test_representation)

    euclidean_distance = source_representation - test_representation
    euclidean_distance = np.sum(np.multiply(euclidean_distance, euclidean_distance))
    euclidean_distance = np.sqrt(euclidean_distance)
    return euclidean_distance

def l2_normalize(x):
    return x / np.sqrt(np.sum(np.multiply(x, x)))

img1_emb = DeepFace.represent("C:/Users/aksha/Downloads/muskan_test.jpg",model_name='Facenet')
img1_emb_arr = np.array(img1_emb)
 
mini=100
user_results = list(db.users.find({}))
distances_list=[]

for user in user_results:
    img2_emb = user['embedding']
    img2_emb_arr = np.array(img2_emb)
    distance = findEuclideanDistance(l2_normalize(img1_emb_arr), l2_normalize(img2_emb_arr))
    distance = np.float64(distance)
    distances_list.append(distance)
    if distance<mini:
        mini=distance
        userID = user['_id']
        userName = user['name']

print(distances_list)
print(userID+" "+userName,mini)