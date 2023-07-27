package ro.any.catalin.etl;

import jakarta.mail.Address;
import jakarta.mail.Authenticator;
import jakarta.mail.Message;
import jakarta.mail.PasswordAuthentication;
import jakarta.mail.Session;
import jakarta.mail.Transport;
import jakarta.mail.internet.AddressException;
import jakarta.mail.internet.InternetAddress;
import jakarta.mail.internet.MimeMessage;
import java.io.File;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.List;
import java.util.Optional;
import java.util.Properties;
import java.util.logging.Logger;
import ro.catalin.crypto.impl.Crypto;

/**
 *
 * @author catalin
 */
public class Mail {
    private static final Logger LOG = Logger.getLogger(Mail.class.getName());
    
    private final Session session;
    private final Properties conf;

    public Mail() throws Exception{
        conf = new Properties();
        try(var _iStream = Files.newInputStream(Paths.get(StartUp.CONF_DIR + File.separator + StartUp.CONF_PROPS_FILE_NAME));){
            conf.load(_iStream);
        }
        
        var _props = new Properties();
        _props.put("mail.smtp.auth", conf.getProperty("mail.smtp.auth"));
        _props.put("mail.smtp.starttls.enable", conf.getProperty("mail.smtp.starttls.enable"));
        _props.put("mail.smtp.host", conf.getProperty("mail.smtp.host"));
        _props.put("mail.smtp.port", conf.getProperty("mail.smtp.port"));
        _props.put("mail.smtp.ssl.trust", conf.getProperty("mail.smtp.ssl.trust"));
        
        var _smtpPwd = Crypto.decrypt(conf.getProperty("mail.smtp.pwd.crypt"));
        this.session = Session.getInstance(_props, new Authenticator(){
            @Override
            protected PasswordAuthentication getPasswordAuthentication() {                
                return new PasswordAuthentication(conf.getProperty("mail.smtp.user"), _smtpPwd);
            }
        });
    }
    
    public void send(String subject, String content, Optional<List<String>> recipients) throws Exception{
        var _message = new MimeMessage(this.session);
        _message.setFrom(new InternetAddress(conf.getProperty("mail.smtp.user")));
        
        if (recipients.isPresent() && !recipients.get().isEmpty()){
            _message.setRecipients(Message.RecipientType.TO, recipients.get().stream()
                .map(x -> {
                    try{
                        return new InternetAddress(x);
                    }catch (AddressException ex){
                        throw new RuntimeException(ex);
                    }
                })
                .toArray(Address[]::new)
            );
        } else {
            _message.setRecipient(Message.RecipientType.TO, new InternetAddress(conf.getProperty("mail.default.recipient")));
        }
        
        _message.setSubject("NAV ETL: " + subject);
        _message.setContent(content, "text/html; charset=utf-8");
        
        Transport.send(_message);
    }
}
