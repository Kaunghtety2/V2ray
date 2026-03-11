FROM shadowsocks/shadowsocks-libev:latest

ENV SERVER_ADDR 0.0.0.0
ENV SERVER_PORT 8388
ENV PASSWORD yourpassword
ENV METHOD chacha20-ietf-poly1305
ENV TIMEOUT 300

EXPOSE 8388

CMD ["sh", "-c", "ss-server -s $SERVER_ADDR -p $SERVER_PORT -k $PASSWORD -m $METHOD -t $TIMEOUT"]