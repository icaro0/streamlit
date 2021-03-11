import streamlit as st
import pandas as pd
import numpy as np
import seaborn as sns
from matplotlib import pyplot as plt

hide_streamlit_style = """
            <style>
            footer {visibility: hidden;}
            #MainMenu {visibility: hidden;}
            .block-container {max-width:none;}
            </style>
            """
st.markdown(hide_streamlit_style, unsafe_allow_html=True)

@st.cache(allow_output_mutation=True)
def load_model():
    df = pd.read_csv('data.csv')
    df['fecha'] = pd.to_datetime(df.fecha)
    df.set_index('fecha', inplace=True)
    return df


st.markdown('# Anomaly detection encoder-decoder')
st.markdown('Puedes mover el threshold para ver las anomalias detectadas bajo ese umbral')

col1, col2 = st.beta_columns(2)


st.sidebar.markdown('Este umbral controla la diferencia en el error de reconstrucción, a menor valor mayor sensibilidad.')
threshold = st.sidebar.slider('Threshold', 0.0, 3.0,value=1.4, step=0.01)

df = load_model()

df['max_trainMAE'] = threshold

fig, ax = plt.subplots(figsize=(10,5))
plt.xticks(rotation=90)
sns.lineplot(x=df.index, y=df['testMAE'], linewidth=2.5, ax=ax)
sns.lineplot(x=df.index, y=df['max_trainMAE'], linewidth=2.5, ax=ax)

with col1:
    col1.markdown('### Umbral sobre la muestra escalada')
    col1.write(fig)


#Plot anomalies
fig2, ax2 = plt.subplots(figsize=(10,5))
plt.xticks(rotation=90)

anomalies = df.loc[df['testMAE'] >= threshold]

sns.lineplot(x=df.index, y=df['neba'], linewidth=2.5, ax=ax2)
sns.scatterplot(x=anomalies.index, y=anomalies['neba'], color='r',s=90, ax=ax2)

with col2:
    col2.markdown('### Gráfico de anomalias detectadas')
    col2.write(fig2)


