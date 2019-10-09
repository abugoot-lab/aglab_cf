FROM ubuntu:16.04

RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections
RUN apt-get update && apt-get install -y software-properties-common
RUN apt-add-repository multiverse
RUN add-apt-repository restricted
RUN add-apt-repository ppa:webupd8team/java
RUN echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections
RUN apt-get update && apt-get install -y \
    wget \
    unzip \
    sudo \
    make \
    gcc \
    libdb-dev \
    libgd-dev \
    zlib1g-dev \
    libxml2-dev \
    libexpat1-dev \
    pkg-config \
    graphviz \
    libssl-dev \
    cpanminus \
    oracle-java8-installer

# Dependencies
RUN cpanm File::Sort Config::Any Bio::FeatureIO Bio::Cluster::SequenceFamily

# Install problematic ::Muscle
RUN cpanm Net::SSLeay LWP::Protocol::https
RUN cpanm Bio::Tools::Eponine # Problematic for Muscle
RUN cpanm Bio::DB::EUtilities # Ensembl requirement
RUN cpanm Bio::Tools::Run::Alignment::Muscle

# Install Samtools
RUN apt-get update && apt-get install -y \
    libncurses5-dev \
    libncursesw5-dev \
    libbz2-dev
WORKDIR /opt/depend/
RUN wget https://github.com/samtools/samtools/releases/download/1.9/samtools-1.9.tar.bz2
RUN bzip2 -d samtools-1.9.tar.bz2
RUN tar xvf samtools-1.9.tar
WORKDIR /opt/depend/samtools-1.9/
RUN make
RUN make install

# Install BEDTools
RUN apt-get update && apt-get install -y \
    python \
    python3-pip
WORKDIR /opt/depend/
RUN wget https://github.com/arq5x/bedtools2/releases/download/v2.25.0/bedtools-2.25.0.tar.gz
RUN tar -zxvf bedtools-2.25.0.tar.gz
WORKDIR /opt/depend/bedtools2/
RUN make
RUN make install

# Download and install
WORKDIR /opt/
RUN wget https://crisprcas.i2bc.paris-saclay.fr/Home/DownloadFile?filename=CRISPRCasFinder.zip -O CRISPRCasFinder.zip
RUN unzip CRISPRCasFinder.zip
WORKDIR /opt/CRISPRCasFinder/
RUN ./installer_UBUNTU.sh

# Install Biopython and pandas; helping packages
RUN pip3 install biopython pandas
RUN pip3 install retrying wget

COPY C4All.py /opt/CRISPRCasFinder/
COPY process_CRISPR.py /opt/CRISPRCasFinder/
COPY C4Nuc.py /opt/CRISPRCasFinder/
COPY Dockerfile /opt/
WORKDIR /opt/CRISPRCasFinder/
ENV PATH="/opt/CRISPRCasFinder/bin:${PATH}"
