import sys, json
import string
import collections
from nltk import word_tokenize
from nltk.stem import PorterStemmer
from nltk.stem.snowball import FinnishStemmer
from nltk.corpus import stopwords
from sklearn.cluster import KMeans
from sklearn.feature_extraction.text import TfidfVectorizer
import string,re
from pprint import pprint
import math
import pandas as pd


def process_text(text, stem=True):
    """ Tokenize text and stem words removing punctuation """

    text = text.translate(None, string.punctuation)
    tokens = word_tokenize(text.decode('utf8'))

    if stem:
        stemmer = FinnishStemmer(ignore_stopwords=True)
        tokens = [stemmer.stem(t) for t in tokens]
        filtered_words = [word for word in tokens if word not in stopwords.words('finnish')]
        filtered_words = [word for word in tokens if word not in stopwords.words('english')]

    return filtered_words




def cluster_texts(texts, clusters, query):
    """ Transform texts to Tf-Idf coordinates and cluster texts using K-Means """
    vectorizer = TfidfVectorizer(lowercase=True,max_df=0.5,min_df=0.1)

    tfidf_model = vectorizer.fit_transform(texts)
    km_model = KMeans(n_clusters=clusters,init='k-means++', max_iter=100, n_init=25)
    km_model.fit(tfidf_model)

    clustering = collections.defaultdict(list)

    for idx, label in enumerate(km_model.labels_):
        clustering[label].append(idx)

    #print("\n\n\nTop terms per cluster:")
    order_centroids = km_model.cluster_centers_.argsort()[:, ::-1]
    terms = vectorizer.get_feature_names()
    #for i in range(clusters):
    #    print("Cluster %d:" % i),
    #    for ind in order_centroids[i, :10]:
    #        print(' %s' % terms[ind]),
    #    print "\n"


    #Prediction
    X = vectorizer.transform(texts)
    clustered_data = km_model.predict(X)

    Y = vectorizer.transform([query])
    prediction = km_model.predict(Y)


    #print("Prediction: "+str(prediction))
    return prediction,clustered_data


def main(jsn,hyper_param):
    #jsn = str(arg)
    #jsn = json.loads(jsn.replace("'",'"'))
    search_query = jsn['preferences']
    job_ids = []
    job_descr = []
    for job in jsn['jobs']:
        #print jsn['jobs'][str(job)]['descr']
        job_ids.append(str(job))
        job_descr.append(jsn['jobs'][str(job)]['descr'])
    tokens = []
    articles = []
    for obj in job_descr:
        discription = obj.encode('utf-8')
        token = process_text(discription)
        tokens.append(token)
        articles.append(' '.join(token))
    k = int(math.floor(len(job_descr)/hyper_param))
    if(k <= 0):
        k = 1;
    prediction,clustered_data = cluster_texts(articles, k, search_query)
    results = pd.DataFrame({'cluster': clustered_data,'result': job_ids})
    #print prediction
    golden_jobs = []
    for index, row in results.iterrows():
        if int(prediction) == int(row['cluster']):
            golden_jobs.append(row['result'])

    if len(golden_jobs) != 0:
        print >> sys.stdout, golden_jobs
    else:
        print >> sys.stdout, False


if __name__ == '__main__':
    hyper_param = sys.argv[2] #range [1,5] can be more
    data = json.load(open(sys.argv[1]))
    main(data,int(hyper_param))



