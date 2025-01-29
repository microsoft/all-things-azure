FROM registry.access.redhat.com/ubi8/ubi-minimal:8.9-1108.1705420507 as build
RUN microdnf -y update && \ 
    microdnf -y install wget && \
    microdnf -y install unzip

RUN wget https://www.hec.usace.army.mil/software/hec-ras/downloads/HEC-RAS_610_Linux.zip

RUN unzip HEC-RAS_610_Linux.zip
RUN unzip HEC-RAS_610_Linux/RAS_Linux_test_setup.zip 

FROM registry.access.redhat.com/ubi8/ubi-minimal:8.9-1108.1705420507 as prod
COPY --from=build /RAS_Linux_test_setup/libs /ras/libs
COPY --from=build /RAS_Linux_test_setup/Ras_v61/Release /ras/v61

RUN chmod +x ras/v61/*

RUN mkdir /sim
WORKDIR /sim
COPY run.sh .
RUN chmod +x run.sh
