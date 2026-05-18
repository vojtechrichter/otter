#include "logging/logging.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#include <arpa/inet.h>

int main(int argc, char **argv)
{
    LOG_INFO("ahoj");
    int server_socket = socket(AF_INET, SOCK_STREAM, 0);

    struct sockaddr_in incoming_address = {
        .sin_family = AF_INET,
        .sin_port = htons(8080),
        .sin_addr.s_addr = INADDR_ANY,
    };

    if (setsockopt(server_socket, SOL_SOCKET, SO_REUSEADDR, &(int){1}, sizeof(int)) < 0) {
    }


    bind(server_socket, (struct sockaddr *)&incoming_address, sizeof(incoming_address));
    listen(server_socket, 4);

    int client_socket = accept(server_socket, NULL, NULL);

    const char *response = "HTTP/1.1 200 OK\r\nContent-Length: 23\r\n\r\nHello from the server\r\n";
    send(client_socket, response, strlen(response), 0);

    close(client_socket);
    close(server_socket);

    return EXIT_SUCCESS;
}
