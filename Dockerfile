FROM continuumio/anaconda3

ADD ./deepracer.yaml  /opt/conda/deepracer.yaml

RUN conda env create --file=/opt/conda/deepracer.yaml
RUN source activate deepracer
RUN python -m ipykernel install --user --name deepracer --display-name "Python (deepracer)"

CMD [ "sh", "--login", "-i" ]
