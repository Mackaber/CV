FROM debian:bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        fonts-noto-core \
        make \
        texlive-fonts-recommended \
        texlive-lang-english \
        texlive-lang-spanish \
        texlive-latex-base \
        texlive-latex-extra \
        texlive-latex-recommended \
        texlive-luatex \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /workdir

CMD ["make", "cv", "LANG=es", "PROFILE=ai-engineer"]
