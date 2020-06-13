import javax.jms.*;
import javax.naming.Context;
import javax.naming.InitialContext;
import java.util.Properties;

public class Publisher {

    public static void main(String args[]) throws Exception {

        Properties props = new Properties();
        props.setProperty(Context.INITIAL_CONTEXT_FACTORY, "org.apache.activemq.jndi.ActiveMQInitialContextFactory");
        props.setProperty(Context.PROVIDER_URL, "tcp://192.168.99.100:61616");

        Context context = new InitialContext(props);

        Connection connection = null;
        try {
            ConnectionFactory connectionFactory = (ConnectionFactory)context.lookup("ConnectionFactory");
            connection = connectionFactory.createConnection("admin", "admin");
            Session session = connection.createSession(false, Session.AUTO_ACKNOWLEDGE);
            Destination destination = (Destination)context.lookup("dynamicQueues/testQueue");

            connection.start();

            MessageProducer messageProducer = session.createProducer(destination);
            System.out.println("Sending message");
            messageProducer.send(session.createTextMessage("This is a sample java message"));

        } finally {
            if(connection != null)
                connection.close();
        }
    }
}
