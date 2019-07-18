/// Copyright (c) 2018 Razeware LLC
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
///
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import Foundation

public enum InternetProtocol: RawRepresentable {
  case ftp, ftpAccount, http, irc, nntp, pop3, smtp, socks, imap, ldap, appleTalk, afp, telnet, ssh, ftps, https, httpProxy, httpsProxy, ftpProxy, smb, rtsp, rtspProxy, daap, eppc, ipp, nntps, ldaps, telnetS, imaps, ircs, pop3S
  
  public init?(rawValue: String) {
    switch rawValue {
    case String(kSecAttrProtocolFTP):
      self = .ftp
    case String(kSecAttrProtocolFTPAccount):
      self = .ftpAccount
    case String(kSecAttrProtocolHTTP):
      self = .http
    case String(kSecAttrProtocolIRC):
      self = .irc
    case String(kSecAttrProtocolNNTP):
      self = .nntp
    case String(kSecAttrProtocolPOP3):
      self = .pop3
    case String(kSecAttrProtocolSMTP):
      self = .smtp
    case String(kSecAttrProtocolSOCKS):
      self = .socks
    case String(kSecAttrProtocolIMAP):
      self = .imap
    case String(kSecAttrProtocolLDAP):
      self = .ldap
    case String(kSecAttrProtocolAppleTalk):
      self = .appleTalk
    case String(kSecAttrProtocolAFP):
      self = .afp
    case String(kSecAttrProtocolTelnet):
      self = .telnet
    case String(kSecAttrProtocolSSH):
      self = .ssh
    case String(kSecAttrProtocolFTPS):
      self = .ftps
    case String(kSecAttrProtocolHTTPS):
      self = .https
    case String(kSecAttrProtocolHTTPProxy):
      self = .httpProxy
    case String(kSecAttrProtocolHTTPSProxy):
      self = .httpsProxy
    case String(kSecAttrProtocolFTPProxy):
      self = .ftpProxy
    case String(kSecAttrProtocolSMB):
      self = .smb
    case String(kSecAttrProtocolRTSP):
      self = .rtsp
    case String(kSecAttrProtocolRTSPProxy):
      self = .rtspProxy
    case String(kSecAttrProtocolDAAP):
      self = .daap
    case String(kSecAttrProtocolEPPC):
      self = .eppc
    case String(kSecAttrProtocolIPP):
      self = .ipp
    case String(kSecAttrProtocolNNTPS):
      self = .nntps
    case String(kSecAttrProtocolLDAPS):
      self = .ldaps
    case String(kSecAttrProtocolTelnetS):
      self = .telnetS
    case String(kSecAttrProtocolIMAPS):
      self = .imaps
    case String(kSecAttrProtocolIRCS):
      self = .ircs
    case String(kSecAttrProtocolPOP3S):
      self = .pop3S
    default:
      self = .http
    }
  }
  
  public var rawValue: String {
    switch self {
    case .ftp:
      return String(kSecAttrProtocolFTP)
    case .ftpAccount:
      return String(kSecAttrProtocolFTPAccount)
    case .http:
      return String(kSecAttrProtocolHTTP)
    case .irc:
      return String(kSecAttrProtocolIRC)
    case .nntp:
      return String(kSecAttrProtocolNNTP)
    case .pop3:
      return String(kSecAttrProtocolPOP3)
    case .smtp:
      return String(kSecAttrProtocolSMTP)
    case .socks:
      return String(kSecAttrProtocolSOCKS)
    case .imap:
      return String(kSecAttrProtocolIMAP)
    case .ldap:
      return String(kSecAttrProtocolLDAP)
    case .appleTalk:
      return String(kSecAttrProtocolAppleTalk)
    case .afp:
      return String(kSecAttrProtocolAFP)
    case .telnet:
      return String(kSecAttrProtocolTelnet)
    case .ssh:
      return String(kSecAttrProtocolSSH)
    case .ftps:
      return String(kSecAttrProtocolFTPS)
    case .https:
      return String(kSecAttrProtocolHTTPS)
    case .httpProxy:
      return String(kSecAttrProtocolHTTPProxy)
    case .httpsProxy:
      return String(kSecAttrProtocolHTTPSProxy)
    case .ftpProxy:
      return String(kSecAttrProtocolFTPProxy)
    case .smb:
      return String(kSecAttrProtocolSMB)
    case .rtsp:
      return String(kSecAttrProtocolRTSP)
    case .rtspProxy:
      return String(kSecAttrProtocolRTSPProxy)
    case .daap:
      return String(kSecAttrProtocolDAAP)
    case .eppc:
      return String(kSecAttrProtocolEPPC)
    case .ipp:
      return String(kSecAttrProtocolIPP)
    case .nntps:
      return String(kSecAttrProtocolNNTPS)
    case .ldaps:
      return String(kSecAttrProtocolLDAPS)
    case .telnetS:
      return String(kSecAttrProtocolTelnetS)
    case .imaps:
      return String(kSecAttrProtocolIMAPS)
    case .ircs:
      return String(kSecAttrProtocolIRCS)
    case .pop3S:
      return String(kSecAttrProtocolPOP3S)
    }
  }
}
