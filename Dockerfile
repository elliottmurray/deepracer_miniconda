FROM continuumio/anaconda3

ADD ./deepracer.yaml  /opt/conda/deepracer.yaml

RUN /bin/bash -c "/opt/conda/bin/conda env create --file=/opt/conda/deepracer.yaml"
RUN /bin/bash -c "source /opt/conda/bin/activate deepracer && python -m ipykernel install --user --name deepracer --display-name \"Python (deepracer)\"" (edited)

CMD [ "sh", "--login", "-i" ]
