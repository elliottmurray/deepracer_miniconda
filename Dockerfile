FROM continuumio/anaconda3

ADD ./deepracer.yaml  /opt/conda/deepracer.yaml


RUN /bin/bash -c "conda env create --file=/opt/conda/deepracer.yaml"
RUN /bin/bash -c "source activate deepracer"
RUN /bin/bash -c "python -m ipykernel install --user --name deepracer --display-name \"Python (deepracer)\""

CMD [ "sh", "--login", "-i" ]
