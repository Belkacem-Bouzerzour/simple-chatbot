from flask import Flask
from flask import request

import nltk
import string
import warnings
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.metrics.pairwise import cosine_similarity

warnings.filterwarnings('ignore')

nltk.download('popular', quiet=True)
# nltk.download('punkt') // TOKENIZER
# nltk.download('wordnet') // Lexical database for the English language

f = open('data.txt', 'r', errors='ignore')
raw = f.read()
raw = raw.lower()

sentence_tokens = nltk.sent_tokenize(raw)
lemmatizer = nltk.stem.WordNetLemmatizer()
remove_punctuation_dict = dict((ord(punctuation), None) for punctuation in string.punctuation)


def lemmatize_tokens(tokens):
    return [lemmatizer.lemmatize(token) for token in tokens]


def lemmatize_normalize(text):
    return lemmatize_tokens(nltk.word_tokenize(text.lower().translate(remove_punctuation_dict)))


def response(user_response):
    sentence_tokens.append(user_response)
    vectorizer = TfidfVectorizer(tokenizer=lemmatize_normalize, stop_words='english')
    # A matrix that describes the frequency of terms that occur in a collection of documents
    document_term_matrix = vectorizer.fit_transform(sentence_tokens)
    # Compute cosine similarity between the user response and all matrix
    similarity = cosine_similarity(document_term_matrix[-1], document_term_matrix)
    # Retrieve the index of the second item from the end (in the sorted version of the matrix)
    index = similarity.argsort()[0][-2]
    # matrix to single row
    flat = similarity.flatten()
    # sort
    flat.sort()
    # retrieve the similarity result
    s = flat[-2]
    if s == 0:
        bot_response = 'I did not understand you.'
        return bot_response
    else:
        bot_response = sentence_tokens[index]
        sentence_tokens.remove(user_response)
        return bot_response


app = Flask(__name__)


@app.route('/')
def hello_world():
    message = request.headers.get('message')
    return response(user_response=message)


if __name__ == '__main__':
    app.run()
