# base image
FROM python:3.8

# streamlit-specific commands for auth if necesary
#RUN mkdir -p /root/.streamlit
#RUN bash -c 'echo -e "\
#[general]\n\
#email = \"\"\n\
#" > /root/.streamlit/credentials.toml'
#RUN bash -c 'echo -e "\
#[server]\n\
#enableCORS = false\n\
#" > /root/.streamlit/config.toml'

# exposing default port for streamlit
EXPOSE 8501

# copy over and install packages
COPY requirements.txt ./requirements.txt
RUN pip3 install -r requirements.txt

# copying everything over
COPY anomaly.py .
COPY data.csv .

# run app
CMD streamlit run anomaly.py