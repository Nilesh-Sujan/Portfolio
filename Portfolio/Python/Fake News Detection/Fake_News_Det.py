from flask import Flask, render_template, request
from sklearn.feature_extraction.text import TfidfVectorizer
import pickle
import pandas as pd
from sklearn.model_selection import train_test_split

app = Flask(__name__)

# Variables initialization
vectorizer = TfidfVectorizer(stop_words='english', max_df=0.7)
model = pickle.load(open('model2.pkl', 'rb'))
df = pd.read_csv('train.csv')

features = df['text']
labels = df['label']

features_train, features_test, labels_train, labels_test = train_test_split(features, labels, test_size=0.2, random_state=0)

def detect_fake_news(input_news):
    tfid_features_train = vectorizer.fit_transform(features_train.values.astype('U'))
    tfid_features_test = vectorizer.transform(features_test.values.astype('U'))
    input_vector = [input_news]
    input_vector_transformed = vectorizer.transform(input_vector)
    prediction = model.predict(input_vector_transformed)
    return prediction

@app.route('/')
def home_page():
    return render_template('index.html')

@app.route('/predict', methods=['POST'])
def predict():
    if request.method == 'POST':
        user_input = request.form['message']
        prediction = detect_fake_news(user_input)
        print(prediction)
        return render_template('index.html', prediction=prediction)
    else:
        return render_template('index.html', prediction="Something went wrong")

if __name__ == '__main__':
    app.run(debug=True)