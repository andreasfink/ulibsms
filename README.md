#ulibgsms
# The Universal Libary: SMS

ulib is a collection of generic useful Objective-C classes which can be used on macOS, iOS, tvOS, watchOS, Linux and probably many other Unixes. It builds on top of Foundation under Apple operating systems and GnuStep's base under Linux. It also used to work  with Cocotron in the past.

ulibsms implements the SMS content PDU functions used in GSM-MAP. It's  the layer7 of the ulib based universal SS7 stack but could also be used for non SS7 applications such as the AT command interface on GSM Modems.


# Related #

ulib is the base class of a family of libraries and applications .It gets used and extended by

* **ulibdb** a libary to query MySQL  Postgres and Redis databases in the same way.  
* **ulibasn1**  a library to make it easier to deal with ASN.1 encoded objects.
* **ulibsmpp** a library to deal with the SMPP protocol
* **ulibsctp** a library to extend ulib with SCTP specific sockets 
* **ulibm2pa** a library implementing the SS7 MTP2 protocol 
* **ulibmtp3** a library implementing the SS7 MTP3 protocol
* **ulibm3ua** a library implementing the SS7 M3UA protocol
* **ulibsccp** a library implementing the SS7 SCCP protocol
* **ulibgt** a library implementing SS7 SCCP Global Title handling
* **ulibtcap** a library implementing the SS7 TCAP protocol
* **ulibgsmmap** a library implementing the SS7 GSM-MAP protocol
* **ulibsms**  a library implementing SMS encoding/decoding functions
* **ulibdns** a library doing DNS functionality
* **schrittmacherclient** a library for applications to implement a hot/standby mechanism
* **schrittmacher** a system daemon dealing with applications in a hot/standby setup, making sure there is always one system hot and one is standby.
* **ulibcnam** a library to deal with CNAM lookups (Number to name translation)
* **messagemover** a application implementing a SS7 GSM-SMSC (commercial)
* **smsproxy** a application implementing a HLR and MSC for receiving SMS on SS7 (commercial)
* **cnam-server** a application implementing a SS7 API Server for all kinds of lookups. (commercial)

