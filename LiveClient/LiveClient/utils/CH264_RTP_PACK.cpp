//
//  UPacket.h
//  LiveClient
//
//  Created by 小布丁 on 2017/2/19.
//  Copyright © 2017年 小布丁. All rights reserved.
//

#ifndef UPacket_h
#define UPacket_h

class CH264_RTP_PACK
{
#define RTP_VERSION 2
    
    typedef struct NAL_msg_s
    {
        bool eoFrame ;
        unsigned char type;     // NAL type
        unsigned char *start;   // pointer to first location in the send buffer
        unsigned char *end; // pointer to last location in send buffer
        unsigned long size ;
    } NAL_MSG_t;
    
    typedef struct
    {
        //LITTLE_ENDIAN
        unsigned short   cc:4;      /* CSRC count                 */
        unsigned short   x:1;       /* header extension flag      */
        unsigned short   p:1;       /* padding flag               */
        unsigned short   v:2;       /* packet type                */
        unsigned short   pt:7;      /* payload type               */
        unsigned short   m:1;       /* marker bit                 */
        
        unsigned short    seq;      /* sequence number            */
        unsigned long     ts;       /* timestamp                  */
        unsigned long     ssrc;     /* synchronization source     */
    } rtp_hdr_t;
    
    typedef struct tagRTP_INFO
    {
        NAL_MSG_t   nal;        // NAL information
        rtp_hdr_t   rtp_hdr;    // RTP header is assembled here
        int hdr_len;            // length of RTP header
        
        unsigned char *pRTP;    // pointer to where RTP packet has beem assembled
        unsigned char *start;   // pointer to start of payload
        unsigned char *end;     // pointer to end of payload
        
        unsigned int s_bit;     // bit in the FU header
        unsigned int e_bit;     // bit in the FU header
        bool FU_flag;       // fragmented NAL Unit flag
    } RTP_INFO;
    
public:
    CH264_RTP_PACK(unsigned long H264SSRC, unsigned char H264PAYLOADTYPE=96, unsigned short MAXRTPPACKSIZE=1472 )
    {
        m_MAXRTPPACKSIZE = MAXRTPPACKSIZE ;
        if ( m_MAXRTPPACKSIZE > 10000 )
        {
            m_MAXRTPPACKSIZE = 10000 ;
        }
        if ( m_MAXRTPPACKSIZE < 50 )
        {
            m_MAXRTPPACKSIZE = 50 ;
        }
        
        memset ( &m_RTP_Info, 0, sizeof(m_RTP_Info) ) ;
        
        m_RTP_Info.rtp_hdr.pt = H264PAYLOADTYPE ;
        m_RTP_Info.rtp_hdr.ssrc = H264SSRC ;
        m_RTP_Info.rtp_hdr.v = RTP_VERSION ;
        
        m_RTP_Info.rtp_hdr.seq = 0 ;
    }
    
    ~CH264_RTP_PACK(void)
    {
    }
    
    //传入Set的数据必须是一个完整的NAL,起始码为0x00000001。
    //起始码之前至少预留10个字节，以避免内存COPY操作。
    //打包完成后，原缓冲区内的数据被破坏。
    bool Set ( unsigned char *NAL_Buf, unsigned long NAL_Size, unsigned long Time_Stamp, bool End_Of_Frame )
    {
        unsigned long startcode = StartCode(NAL_Buf) ;
        
        if ( startcode != 0x01000000 )
        {
            return false ;
        }
        
        int type = NAL_Buf[4] & 0x1f ;
        if ( type < 1 || type > 12 )
        {
            return false ;
        }
        
        m_RTP_Info.nal.start = NAL_Buf ;
        m_RTP_Info.nal.size = NAL_Size ;
        m_RTP_Info.nal.eoFrame = End_Of_Frame ;
        m_RTP_Info.nal.type = m_RTP_Info.nal.start[4] ;
        m_RTP_Info.nal.end = m_RTP_Info.nal.start + m_RTP_Info.nal.size ;
        
        m_RTP_Info.rtp_hdr.ts = Time_Stamp ;
        
        m_RTP_Info.nal.start += 4 ; // skip the syncword
        
        if ( (m_RTP_Info.nal.size + 7) > m_MAXRTPPACKSIZE )
        {
            m_RTP_Info.FU_flag = true ;
            m_RTP_Info.s_bit = 1 ;
            m_RTP_Info.e_bit = 0 ;
            
            m_RTP_Info.nal.start += 1 ; // skip NAL header
        }
        else
        {
            m_RTP_Info.FU_flag = false ;
            m_RTP_Info.s_bit = m_RTP_Info.e_bit = 0 ;
        }
        
        m_RTP_Info.start = m_RTP_Info.end = m_RTP_Info.nal.start ;
        m_bBeginNAL = true ;
        
        return true ;
    }
    
    //循环调用Get获取RTP包，直到返回值为NULL
    unsigned char* Get ( unsigned short *pPacketSize )
    {
        if ( m_RTP_Info.end == m_RTP_Info.nal.end )
        {
            *pPacketSize = 0 ;
            return NULL ;
        }
        
        if ( m_bBeginNAL )
        {
            m_bBeginNAL = false ;
        }
        else
        {
            m_RTP_Info.start = m_RTP_Info.end;  // continue with the next RTP-FU packet
        }
        
        int bytesLeft = m_RTP_Info.nal.end - m_RTP_Info.start ;
        int maxSize = m_MAXRTPPACKSIZE - 12 ;   // sizeof(basic rtp header) == 12 bytes
        if ( m_RTP_Info.FU_flag )
            maxSize -= 2 ;
        
        if ( bytesLeft > maxSize )
        {
            m_RTP_Info.end = m_RTP_Info.start + maxSize ;   // limit RTP packetsize to 1472 bytes
        }
        else
        {
            m_RTP_Info.end = m_RTP_Info.start + bytesLeft ;
        }
        
        if ( m_RTP_Info.FU_flag )
        {   // multiple packet NAL slice
            if ( m_RTP_Info.end == m_RTP_Info.nal.end )
            {
                m_RTP_Info.e_bit = 1 ;
            }
        }
        
        m_RTP_Info.rtp_hdr.m =  m_RTP_Info.nal.eoFrame ? 1 : 0 ; // should be set at EofFrame
        if ( m_RTP_Info.FU_flag && !m_RTP_Info.e_bit )
        {
            m_RTP_Info.rtp_hdr.m = 0 ;
        }
        
        m_RTP_Info.rtp_hdr.seq++ ;
        
        unsigned char *cp = m_RTP_Info.start ;
        cp -= ( m_RTP_Info.FU_flag ? 14 : 12 ) ;
        m_RTP_Info.pRTP = cp ;
        
        unsigned char *cp2 = (unsigned char *)&m_RTP_Info.rtp_hdr ;
        cp[0] = cp2[0] ;
        cp[1] = cp2[1] ;
        
        cp[2] = ( m_RTP_Info.rtp_hdr.seq >> 8 ) & 0xff ;
        cp[3] = m_RTP_Info.rtp_hdr.seq & 0xff ;
        
        cp[4] = ( m_RTP_Info.rtp_hdr.ts >> 24 ) & 0xff ;
        cp[5] = ( m_RTP_Info.rtp_hdr.ts >> 16 ) & 0xff ;
        cp[6] = ( m_RTP_Info.rtp_hdr.ts >>  8 ) & 0xff ;
        cp[7] = m_RTP_Info.rtp_hdr.ts & 0xff ;
        
        cp[8] =  ( m_RTP_Info.rtp_hdr.ssrc >> 24 ) & 0xff ;
        cp[9] =  ( m_RTP_Info.rtp_hdr.ssrc >> 16 ) & 0xff ;
        cp[10] = ( m_RTP_Info.rtp_hdr.ssrc >>  8 ) & 0xff ;
        cp[11] = m_RTP_Info.rtp_hdr.ssrc & 0xff ;
        m_RTP_Info.hdr_len = 12 ;
        /*!
         * /n The FU indicator octet has the following format:
         * /n
         * /n      +---------------+
         * /n MSB  |0|1|2|3|4|5|6|7|  LSB
         * /n      +-+-+-+-+-+-+-+-+
         * /n      |F|NRI|  Type   |
         * /n      +---------------+
         * /n
         * /n The FU header has the following format:
         * /n
         * /n      +---------------+
         * /n      |0|1|2|3|4|5|6|7|
         * /n      +-+-+-+-+-+-+-+-+
         * /n      |S|E|R|  Type   |
         * /n      +---------------+
         */
        if ( m_RTP_Info.FU_flag )
        {
            // FU indicator  F|NRI|Type
            cp[12] = ( m_RTP_Info.nal.type & 0xe0 ) | 28 ;  //Type is 28 for FU_A
            //FU header     S|E|R|Type
            cp[13] = ( m_RTP_Info.s_bit << 7 ) | ( m_RTP_Info.e_bit << 6 ) | ( m_RTP_Info.nal.type & 0x1f ) ; //R = 0, must be ignored by receiver
            
            m_RTP_Info.s_bit = m_RTP_Info.e_bit= 0 ;
            m_RTP_Info.hdr_len = 14 ;
        }
        m_RTP_Info.start = &cp[m_RTP_Info.hdr_len] ;    // new start of payload
        
        *pPacketSize = m_RTP_Info.hdr_len + ( m_RTP_Info.end - m_RTP_Info.start ) ;
        return m_RTP_Info.pRTP ;
    }
    
private:
    unsigned int StartCode( unsigned char *cp )
    {
        unsigned int d32 ;
        d32 = cp[3] ;
        d32 <<= 8 ;
        d32 |= cp[2] ;
        d32 <<= 8 ;
        d32 |= cp[1] ;
        d32 <<= 8 ;
        d32 |= cp[0] ;
        return d32 ;
    }
    
private:
    RTP_INFO m_RTP_Info ;
    bool m_bBeginNAL ;
    unsigned short m_MAXRTPPACKSIZE ;
};

// class CH264_RTP_PACK end
//////////////////////////////////////////////////////////////////////////////////////////


//////////////////////////////////////////////////////////////////////////////////////////
// class CH264_RTP_UNPACK start

class CH264_RTP_UNPACK
{
    
#define RTP_VERSION 2
#define BUF_SIZE (1024 * 500)
    
    typedef struct
    {
        //LITTLE_ENDIAN
        unsigned short   cc:4;      /* CSRC count                 */
        unsigned short   x:1;       /* header extension flag      */
        unsigned short   p:1;       /* padding flag               */
        unsigned short   v:2;       /* packet type                */
        unsigned short   pt:7;      /* payload type               */
        unsigned short   m:1;       /* marker bit                 */
        
        unsigned short    seq;      /* sequence number            */
        unsigned long     ts;       /* timestamp                  */
        unsigned long     ssrc;     /* synchronization source     */
    } rtp_hdr_t;
public:
    
    CH264_RTP_UNPACK ( HRESULT &hr, unsigned char H264PAYLOADTYPE = 96 )
    : m_bSPSFound(false)
    , m_bWaitKeyFrame(true)
    , m_bPrevFrameEnd(false)
    , m_bAssemblingFrame(false)
    , m_wSeq(1234)
    , m_ssrc(0)
    {
        m_pBuf = new BYTE[BUF_SIZE] ;
        if ( m_pBuf == NULL )
        {
            hr = E_OUTOFMEMORY ;
            return ;
        }
        
        m_H264PAYLOADTYPE = H264PAYLOADTYPE ;
        m_pEnd = m_pBuf + BUF_SIZE ;
        m_pStart = m_pBuf ;
        m_dwSize = 0 ;
        hr = S_OK ;
    }
    
    ~CH264_RTP_UNPACK(void)
    {
        delete [] m_pBuf ;
    }
    
    //pBuf为H264 RTP视频数据包，nSize为RTP视频数据包字节长度，outSize为输出视频数据帧字节长度。
    //返回值为指向视频数据帧的指针。输入数据可能被破坏。
    BYTE* Parse_RTP_Packet ( BYTE *pBuf, unsigned short nSize, int *outSize )
    {
        if ( nSize <= 12 )
        {
            return NULL ;
        }
        
        BYTE *cp = (BYTE*)&m_RTP_Header ;
        cp[0] = pBuf[0] ;
        cp[1] = pBuf[1] ;
        
        m_RTP_Header.seq = pBuf[2] ;
        m_RTP_Header.seq <<= 8 ;
        m_RTP_Header.seq |= pBuf[3] ;
        
        m_RTP_Header.ts = pBuf[4] ;
        m_RTP_Header.ts <<= 8 ;
        m_RTP_Header.ts |= pBuf[5] ;
        m_RTP_Header.ts <<= 8 ;
        m_RTP_Header.ts |= pBuf[6] ;
        m_RTP_Header.ts <<= 8 ;
        m_RTP_Header.ts |= pBuf[7] ;
        
        m_RTP_Header.ssrc = pBuf[8] ;
        m_RTP_Header.ssrc <<= 8 ;
        m_RTP_Header.ssrc |= pBuf[9] ;
        m_RTP_Header.ssrc <<= 8 ;
        m_RTP_Header.ssrc |= pBuf[10] ;
        m_RTP_Header.ssrc <<= 8 ;
        m_RTP_Header.ssrc |= pBuf[11] ;
        
        BYTE *pPayload = pBuf + 12 ;
        DWORD PayloadSize = nSize - 12 ;
        
        // Check the RTP version number (it should be 2):
        if ( m_RTP_Header.v != RTP_VERSION )
        {
            return NULL ;
        }
        
        /*
         // Skip over any CSRC identifiers in the header:
         if ( m_RTP_Header.cc )
         {
         long cc = m_RTP_Header.cc * 4 ;
         if ( Size < cc )
         {
         return NULL ;
         }
         
         Size -= cc ;
         p += cc ;
         }
         
         // Check for (& ignore) any RTP header extension
         if ( m_RTP_Header.x )
         {
         if ( Size < 4 )
         {
         return NULL ;
         }
         
         Size -= 4 ;
         p += 2 ;
         long l = p[0] ;
         l <<= 8 ;
         l |= p[1] ;
         p += 2 ;
         l *= 4 ;
         if ( Size < l ) ;
         {
         return NULL ;
         }
         Size -= l ;
         p += l ;
         }
         
         // Discard any padding bytes:
         if ( m_RTP_Header.p )
         {
         if ( Size == 0 )
         {
         return NULL ;
         }
         long Padding = p[Size-1] ;
         if ( Size < Padding )
         {
         return NULL ;
         }
         Size -= Padding ;
         }*/
        
        // Check the Payload Type.
        if ( m_RTP_Header.pt != m_H264PAYLOADTYPE )
        {
            return NULL ;
        }
        
        int PayloadType = pPayload[0] & 0x1f ;
        int NALType = PayloadType ;
        if ( NALType == 28 ) // FU_A
        {
            if ( PayloadSize < 2 )
            {
                return NULL ;
            }
            
            NALType = pPayload[1] & 0x1f ;
        }
        
        if ( m_ssrc != m_RTP_Header.ssrc )
        {
            m_ssrc = m_RTP_Header.ssrc ;
            SetLostPacket () ;
        }
        
        if ( NALType == 0x07 ) // SPS
        {
            m_bSPSFound = true ;
        }
        
        if ( !m_bSPSFound )
        {
            return NULL ;
        }
        
        if ( NALType == 0x07 || NALType == 0x08 ) // SPS PPS
        {
            m_wSeq = m_RTP_Header.seq ;
            m_bPrevFrameEnd = true ;
            
            pPayload -= 4 ;
            *((DWORD*)(pPayload)) = 0x01000000 ;
            *outSize = PayloadSize + 4 ;
            return pPayload ;
        }
        
        if ( m_bWaitKeyFrame )
        {
            if ( m_RTP_Header.m ) // frame end
            {
                m_bPrevFrameEnd = true ;
                if ( !m_bAssemblingFrame )
                {
                    m_wSeq = m_RTP_Header.seq ;
                    return NULL ;
                }
            }
            
            if ( !m_bPrevFrameEnd )
            {
                m_wSeq = m_RTP_Header.seq ;
                return NULL ;
            }
            else
            {
                if ( NALType != 0x05 ) // KEY FRAME
                {
                    m_wSeq = m_RTP_Header.seq ;
                    m_bPrevFrameEnd = false ;
                    return NULL ;
                }
            }
        }
        
        
        ///////////////////////////////////////////////////////////////
        
        if ( m_RTP_Header.seq != (WORD)( m_wSeq + 1 ) ) // lost packet
        {
            m_wSeq = m_RTP_Header.seq ;
            SetLostPacket () ;
            return NULL ;
        }
        else
        {
            // 码流正常
            
            m_wSeq = m_RTP_Header.seq ;
            m_bAssemblingFrame = true ;
            
            if ( PayloadType != 28 ) // whole NAL
            {
                *((DWORD*)(m_pStart)) = 0x01000000 ;
                m_pStart += 4 ;
                m_dwSize += 4 ;
            }
            else // FU_A
            {
                if ( pPayload[1] & 0x80 ) // FU_A start
                {
                    *((DWORD*)(m_pStart)) = 0x01000000 ;
                    m_pStart += 4 ;
                    m_dwSize += 4 ;
                    
                    pPayload[1] = ( pPayload[0] & 0xE0 ) | NALType ;
                    
                    pPayload += 1 ;
                    PayloadSize -= 1 ;
                }
                else
                {
                    pPayload += 2 ;
                    PayloadSize -= 2 ;
                }
            }
            
            if ( m_pStart + PayloadSize < m_pEnd )
            {
                CopyMemory ( m_pStart, pPayload, PayloadSize ) ;
                m_dwSize += PayloadSize ;
                m_pStart += PayloadSize ;
            }
            else // memory overflow
            {
                SetLostPacket () ;
                return NULL ;
            }
            
            if ( m_RTP_Header.m ) // frame end
            {
                *outSize = m_dwSize ;
                
                m_pStart = m_pBuf ;
                m_dwSize = 0 ;
                
                if ( NALType == 0x05 ) // KEY FRAME
                {
                    m_bWaitKeyFrame = false ;
                }
                return m_pBuf ;
            }
            else
            {
                return NULL ;
            }
        }
    }
    
    void SetLostPacket()
    {
        m_bSPSFound = false ;
        m_bWaitKeyFrame = true ;
        m_bPrevFrameEnd = false ;
        m_bAssemblingFrame = false ;
        m_pStart = m_pBuf ;
        m_dwSize = 0 ;
    }
    
private:
    rtp_hdr_t m_RTP_Header ;
    
    BYTE *m_pBuf ;
    
    bool m_bSPSFound ;
    bool m_bWaitKeyFrame ;
    bool m_bAssemblingFrame ;
    bool m_bPrevFrameEnd ;  
    BYTE *m_pStart ;  
    BYTE *m_pEnd ;  
    DWORD m_dwSize ;  
    
    WORD m_wSeq ;  
    
    BYTE m_H264PAYLOADTYPE ;  
    DWORD m_ssrc ;  
};  

// class CH264_RTP_UNPACK end

#endif /* UPacket_h */
