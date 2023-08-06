FROM python:3.10

WORKDIR /mkdocs

COPY mkdocs.yml ./

COPY ./docs /mkdocs/docs

RUN pip install mkdocs

RUN pip install mkdocs-material

EXPOSE 8080

CMD ["mkdocs", "serve"]