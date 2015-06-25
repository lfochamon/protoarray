import socket, sys

# HOST = '192.168.7.2'  # Remote host
# HOST = '192.168.0.111'  # Remote host
HOST = '192.168.0.2'    # Remote host
PORT = 54321            # Remote port
MSG_SIZE = 100


def substr_iter(data, length):
    for i in range(0, len(data), length):
            yield int(i/length), data[i:i+length]


# Open TCP socket
sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
sock.settimeout(1)

# Connect to server
sock.connect((HOST, PORT))

# Handshake with server
sock.send(b"Ready")

full1 = []
full2 = []
grand_total = 0

total = 0
while total < MSG_SIZE:
    try:
        data = sock.recv(int(MSG_SIZE/4))
        full1.append(data)
        total = total + len(data)
    except socket.timeout:
        print("The socket timed out during buffer", i)
        sock.close()
        sys.exit(-1)

grand_total = grand_total + total


total = 0
while total < MSG_SIZE:
    try:
        data = sock.recv(int(MSG_SIZE/4))
        full2.append(data)
        total = total + len(data)
    except socket.timeout:
        print("The socket timed out during buffer", i)
        sock.close()
        sys.exit(-1)

grand_total = grand_total + total


# Close socket
sock.close()

# Integrity check
full1 = b"".join(full1)
full2 = b"".join(full2)

print("The client received", grand_total "B from the server.")

if all(idx == int.from_bytes(c, 'little')-1 for idx, c in substr_iter(full1, 4)):
    if all(idx == int.from_bytes(c, 'little')-1 for idx, c in substr_iter(full1, 4)):
        print("Messages passed the integrity check")
