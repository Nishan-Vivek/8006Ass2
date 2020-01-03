# BCIT COMP8006 Assignment 2 - Linux firewall and packet filter

# Objective 

To design, implement and test a standalone Linux firewall and packet
filter.

## Requirements

  - Inbound/Outbound TCP packets on allowed ports.

  - Inbound/Outbound UDP packets on allowed ports.

  - Inbound/Outbound ICMP packets based on type numbers.

  - All packets that fall through to the default rule will be dropped.

  - Drop all packets destined for the firewall host from the outside.

  - Do not accept any packets with a source address from the outside
    matching your internal network.

  - You must ensure the you reject those connections that are coming the
    “wrong” way (i.e., inbound SYN packets to high ports).

  - Accept fragments.

  - Accept all TCP packets that belong to an existing connection (on
    allowed ports).

  - Drop all TCP packets with the SYN and FIN bit set.

  - Do not allow Telnet packets at all.

  - Block all external traffic directed to ports 32768 – 32775, 137 –
    139, TCP ports 111 and 515.

  - For FTP and SSH services, set control connections to "Minimum Delay"
    and FTP data to "Maximum Throughput".

## Initial Design

### Network Diagram

![](.//media/image1.png)

### Design Diagrams

### Incoming Packets

![](.//media/image2.png)

### Outgoing Packets

![](.//media/image3.png)

## Implementation 

The project is implemented as a Bash Shell Script to configure the
firewall machine and two ruby scripts to run hping tests from within the
network and from the outside. All scripts have a user configurable
section at the beginning where the correct IP information can be input
as per the test environment and the ports to be explicitly allowed and
blocked can be customized.

## Execution Instructions

Extract the submitted zip file on the respective firewall machine and
navigate to the “Firewall” folder. As root run the firewall.sh script
with the following command line:

`./firewall.sh`

If you wish to reset the firewall to accept all run the script with the
“stop” parameter:

`./firewall.sh stop`

For the outgoing packet tests load the outbound.rb script file on the
client computer in the internal network. Ensure ruby and hping are
installed and run with the following command:

`ruby outbound.vb`

Check the results the created “Outbound\_Firewall\_Test.txt” file.

For the inbound packet tests load the inbound.rb script file on a
computer on the external network. Ensure ruby and hping are installed
and run with the following command:

`ruby inbound.vb`

Check the results in the created “Inbound\_Firewall\_Test.txt” file.

## Tests Results

See included “Inbound\_Firewall\_Test.txt” and
“Outbound\_Firewall\_Test.txt” for test script results.
