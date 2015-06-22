#include "tcpServer.h"


void socketInfo(int socketfd){
	int optval;
	int optlen;

	/* Don't send out partial frames. Useful for prepending headers or for throughput
	 * optimization. There is a 200 ms ceiling on the time for which output is corked.
	 * Can be combined with TCP_NODELAY only for Linux > 2.5.71. */
	printf("TCP_CORK: ");
	getsockopt(socketfd, IPPROTO_TCP, TCP_CORK, &optval, &optlen);
	if(optval == 0)
		printf("No\n");
	else
		printf("Yes\n");

	/* Allow a listener to be awakened only when data arrives on the socket.
	 * Takes an integer value (seconds). */
	printf("TCP_DEFER_ACCEPT: ");
	getsockopt(socketfd, IPPROTO_TCP, TCP_DEFER_ACCEPT, &optval, &optlen);
	printf("%d s\n", optval);

	/* Maximum number of keepalive probes TCP should send before dropping the connection. */
	printf("TCP_KEEPCNT: ");
	getsockopt(socketfd, IPPROTO_TCP, TCP_KEEPCNT, &optval, &optlen);
	printf("%d times\n", optval);

	/* Time (seconds) the connection needs to remain idle before TCP starts
	 * sending keepalive probes (if SO_KEEPALIVE is set). */
	printf("TCP_KEEPIDLE: ");
	getsockopt(socketfd, IPPROTO_TCP, TCP_KEEPIDLE, &optval, &optlen);
	printf("%d s\n", optval);

	/* Time (seconds) between individual keepalive probes. */
	printf("TCP_KEEPINTVL: ");
	getsockopt(socketfd, IPPROTO_TCP, TCP_KEEPINTVL, &optval, &optlen);
	printf("%d s\n", optval);

	/* The maximum segment size for outgoing TCP packets. TCP will also impose its
	 * minimum and maximum bounds over the value provided. */
	printf("TCP_MAXSEG: ");
	getsockopt(socketfd, IPPROTO_TCP, TCP_MAXSEG, &optval, &optlen);
	printf("%d\n", optval);

	/* Disable the Nagle algorithm (segments are always sent as soon as possible).
	 * When not set, data is buffered. Overridden by TCP_CORK. However, forces an
	 * explicit flush of pending output, even if TCP_CORK is set. */
	printf("TCP_NODELAY: ");
	getsockopt(socketfd, IPPROTO_TCP, TCP_NODELAY, &optval, &optlen);
	if(optval == 0)
		printf("No\n");
	else
		printf("Yes\n");

	/* Enable quickack mode (ACKs are sent immediately). Not permanent: only enables
	 * a switch to or from quickack mode. Subsequent operations will enter/leave
	 * quickack mode depending on internal protocol processing. */
	printf("TCP_QUICKACK: ");
	getsockopt(socketfd, IPPROTO_TCP, TCP_QUICKACK, &optval, &optlen);
	if(optval == 0)
		printf("No\n");
	else
		printf("Yes\n");

	/* Number of SYN retransmits before aborting the attempt to connect (< 255). */
	printf("TCP_SYNCNT: ");
	getsockopt(socketfd, IPPROTO_TCP, TCP_SYNCNT, &optval, &optlen);
	printf("%d\n", optval);

	/* Bound the size of the advertised window to this value (> SOCK_MIN_RCVBUF/2). */
	printf("TCP_WINDOW_CLAMP: ");
	getsockopt(socketfd, IPPROTO_TCP, TCP_WINDOW_CLAMP, &optval, &optlen);
	printf("%d\n", optval);
}



int createSocket(){
	int socketfd;
	int yes = 1;
	struct sockaddr_in serverAddress;

	// Try to create a new socket
	socketfd = socket(AF_INET, SOCK_STREAM, 0);
	if (socketfd < 0){
		perror("Error opening socket\n");
		exit(EXIT_FAILURE);
	}

	// Mount address struct: listen on internet, on any address, and on [portnumber]
	memset((char *) &serverAddress, 0, sizeof(serverAddress));
	serverAddress.sin_family = AF_INET;
	serverAddress.sin_addr.s_addr = htonl(INADDR_ANY);
	serverAddress.sin_port = htons(PORT);

	// Avoid the "Address already in use" error message
	if (setsockopt(socketfd, SOL_SOCKET, SO_REUSEADDR, &yes, sizeof(int)) == -1){
			perror("Error setting socket options. Will try to go on anyway...\n");
	}

	// Bind socket to port
	if (bind(socketfd, (struct sockaddr *) &serverAddress, sizeof(serverAddress)) < 0){
		perror("Error while binding listening socket\n");
		exit(EXIT_FAILURE);
	}

	// Return the socket file descriptor
	return(socketfd);
}


int getClientSocket(){
	int serverSocket, clientSocket;
	struct sockaddr_in clientAddress;
	socklen_t clientLength;

	// Create and bind server socket
	serverSocket = createSocket();

  // Listen on port until connection from a client socket
  if (listen(serverSocket, BACKLOG) == -1) {
    perror("Error while listening on socket");
    exit(EXIT_FAILURE);
  }

  // Accept client connection and get the client's socket information
  clientLength = sizeof(clientAddress);
  clientSocket = accept(serverSocket, (struct sockaddr *) &clientAddress, &clientLength);

  if (clientSocket < 0){
    perror("Failed to bind the client socket properly\n");
    exit(EXIT_FAILURE);
  }

  // Close server socket (no need for it anymore)
  close(serverSocket);

	// Return client socket file descriptor
	return(clientSocket);
}


int receiveData(int clientSocket, char *readBuffer, int size){
	int n;

	// Read [size] bytes from client socket
  n = recv(clientSocket, readBuffer, size, 0);

  if (n < 0){
    perror("Error reading socket");
    exit(EXIT_FAILURE);
  }

	#ifdef __DEBUG__
		printf("Received %d/%d bytes.\n", n, size);
	#endif /* __DEBUG__ */

  readBuffer[n] = '\0';

	return(n);
}


int receiveall(int clientSocket, char *readBuffer, int size){
	int received = 0;
	int n;

	while(received < size) {
		n = recv(clientSocket, readBuffer + received, size - received, 0);

		if (n < 0){
			perror("Error reading socket");
			exit(EXIT_FAILURE);
		}

		received += n;

		#ifdef __DEBUG__
			printf("Received %d/%d bytes.\n", n, size);
		#endif /* __DEBUG__ */
	}

	readBuffer[received] = '\0';

	return(received);
}


int sendData(int clientSocket, char *writeBuffer, int size){
	int n;

	// Send [size] bytes of [writeBuffer]
	n = send(clientSocket, writeBuffer, size, 0);
	if (n < 0){
		perror("Error writing to socket");
		exit(EXIT_FAILURE);
	}

	#ifdef __DEBUG__
		printf("Sent %d/%d bytes.\n", n, size);
	#endif /* __DEBUG__ */

	return(n);
}


int sendall(int clientSocket, char *writeBuffer, int size){
	int sent = 0;
	int n;

	while(sent < size) {
		n = send(clientSocket, writeBuffer + sent, size - sent, 0);

		if (n < 0){
			perror("Error writing to socket");
			exit(EXIT_FAILURE);
		}

		sent += n;

		#ifdef __DEBUG__
			printf("Sent %d/%d bytes.\n", n, size);
		#endif /* __DEBUG__ */
	}

	return(sent);
}
