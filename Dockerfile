FROM busybox:ubuntu-14.04

ADD build/linux/gost /gost
RUN chmod u+x gost
