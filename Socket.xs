#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include <fcntl.h>
#include <sys/types.h>
#include <sys/socket.h>

MODULE = POSIX::Socket    PACKAGE = POSIX::Socket   PREFIX = smh

IV
smh_close(fd)
    IV fd

    PROTOTYPE: DISABLE

    CODE:
    RETVAL = close(fd);
    OUTPUT:
    RETVAL

IV
smh_socket(socket_family, socket_type, protocol)
    IV socket_family;
    IV socket_type;
    IV protocol;

    PROTOTYPE: DISABLE

    CODE:
    RETVAL = socket(socket_family, socket_type, protocol);
    OUTPUT:
    RETVAL

#ifndef WIN32

IV
smh_fcntl(fildes, cmd, arg)
    IV fildes;
    IV cmd;
    IV arg;

    PROTOTYPE: DISABLE

    CODE:
    RETVAL = fcntl(fildes, cmd, arg);
    OUTPUT:
    RETVAL

#endif

IV
smh_bind(fd, addr)
    IV fd;
    SV * addr;

    PROTOTYPE: DISABLE
    PREINIT:
    STRLEN addrlen;
    char *sockaddr_pv = SvPVbyte(addr, addrlen);

    CODE:
    RETVAL = bind(fd, (struct sockaddr*)sockaddr_pv, addrlen);
    OUTPUT:
    RETVAL

IV
smh_connect(fd, addr)
    IV fd;
    SV * addr;

    PROTOTYPE: DISABLE
    PREINIT:
    STRLEN addrlen;
    char *sockaddr_pv = SvPVbyte(addr, addrlen);

    CODE:
    RETVAL = connect(fd, (struct sockaddr*)sockaddr_pv, addrlen);
    OUTPUT:
    RETVAL

IV
smh_recv(fd, sv_buffer, len, flags)
    IV fd;
    SV * sv_buffer;
    IV len;
    IV flags;

    PREINIT:
    int count;

    PROTOTYPE: DISABLE

    CODE:
    if (!SvOK(sv_buffer)) {
         sv_setpvn(sv_buffer, "", 0);
    }
    SvUPGRADE((SV*)ST(1), SVt_PV);
    sv_buffer = (SV*)SvGROW((SV*)ST(1), len);
    count = recv(fd, sv_buffer, len, flags);
    if (count >= 0)
    {
        SvCUR_set((SV*)ST(1), count);
        SvTAINT(ST(1));
        SvSETMAGIC(ST(1));
    }
    RETVAL = count;

    OUTPUT:
    RETVAL

IV
smh_recvn(fd, sv_buffer, len, flags)
    IV fd;
    SV * sv_buffer;
    IV len;
    IV flags;

    PREINIT:
    int nrecv;
    int nleft = len;
    void * ptr;

    PROTOTYPE: DISABLE

    CODE:
    if (!SvOK(sv_buffer)) {
         sv_setpvn(sv_buffer, "", 0);
    }
    SvUPGRADE((SV*)ST(1), SVt_PV);
    sv_buffer = (SV*)SvGROW((SV*)ST(1), len);
    ptr = (void *) sv_buffer;
    RETVAL = len;
    while (nleft > 0)
    {
        nrecv = recv(fd, ptr, nleft, flags);
        if (nrecv == -1)
        {
            if ((errno == EAGAIN) || (errno == EWOULDBLOCK) || (errno == EINTR))
            {
                continue;
            } else {
                RETVAL = -1;
                break;
            }
        }
        else if (nrecv == 0)
        {
            RETVAL = 0;
            break;
        }
        else
        {
            nleft -= nrecv;
            ptr += nrecv;
        }
 
    }
    SvCUR_set((SV*)ST(1), len-nleft);
    SvTAINT(ST(1));
    SvSETMAGIC(ST(1));

    OUTPUT:
    RETVAL


IV
smh_getsockname(fd, sv_sock_addr)
    IV fd;
    SV * sv_sock_addr;

    PREINIT:
    int count = sizeof(struct sockaddr);
    char * sock_addr;

    PROTOTYPE: DISABLE

    CODE:
    if (!SvOK(sv_sock_addr)) {
         sv_setpvn(sv_sock_addr, "", 0);
    }
    SvUPGRADE((SV*)ST(1), SVt_PV);
    sv_sock_addr = (SV*)SvGROW((SV*)ST(1), count);
    RETVAL = getsockname(fd, (struct sockaddr*)sv_sock_addr, &count);
    if (count >= 0)
    {
        SvCUR_set((SV*)ST(1), count);
        SvTAINT(ST(1));
        SvSETMAGIC(ST(1));
    }

    OUTPUT:
    RETVAL


IV
smh_send(fd, buf, flags)
    IV fd;
    SV * buf;
    IV flags;

    PROTOTYPE: DISABLE
    PREINIT:
    STRLEN len;
    char *msg = SvPVbyte(buf, len);


    CODE:
    RETVAL = send(fd, msg, len, flags);
    OUTPUT:
    RETVAL

IV
smh_sendn(fd, buf, flags)
    IV fd;
    SV * buf;
    IV flags;
    
    PROTOTYPE: DISABLE

    PREINIT:
    STRLEN len;
    char *msg = SvPVbyte(buf, len);
    int nwritten;
    int nleft = len;
    
    CODE:
    RETVAL = len;
    while (nleft > 0)
    {
        nwritten = send(fd, msg, nleft, flags);
        if (nwritten == -1)
        {
            if ((errno == EAGAIN) || (errno == EWOULDBLOCK) || (errno == EINTR))
            {
                continue;
            } else {
                RETVAL = -1;
                break;
            }
        }
        else
        {
            nleft -= nwritten;
            msg += nwritten;
        }
    }

    OUTPUT:
    RETVAL
    

IV
smh_sendto(fd, buf, flags, dest_addr)
    IV fd;
    SV * buf;
    IV flags;
    SV * dest_addr;

    PROTOTYPE: DISABLE
    PREINIT:
    STRLEN addrlen;
    STRLEN len;
    char *msg = SvPVbyte(buf,len);
    char *sockaddr_pv = SvPVbyte(dest_addr, addrlen);


    CODE:
    RETVAL = sendto(fd, msg, len, flags, (struct sockaddr*)sockaddr_pv, addrlen);
    OUTPUT:
    RETVAL

IV
smh_accept(fd)
    IV fd;

    PROTOTYPE: DISABLE

    CODE:
    RETVAL = accept(fd, NULL, NULL);
    OUTPUT:
    RETVAL
    
IV
smh_listen(fd, backlog)
    IV fd;
    IV backlog;

    PROTOTYPE: DISABLE

    CODE:
    RETVAL = listen(fd, backlog);
    OUTPUT:
    RETVAL

