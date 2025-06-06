
class AppConstants {

  AppConstants._();

  // --- URLs Base de la API ---

  static const String _localApiIp = "192.168.1.132"; // IP LOCAL
  static const String _localApiPort = "8080";
  static const String _localApiProtocol = "http";

  // URL base para el backend local
  // static const String localApiBaseUrl = "$_localApiProtocol://$_localApiIp:$_localApiPort/api";
  
  static const String prodApiBaseUrl = "https://cryptoacademy-tfg-production.up.railway.app/api";

  static const String activeApiBaseUrl = prodApiBaseUrl; // Cambia a prodApiBaseUrl en producción

  // --- Endpoints específicos

  static const String authEndpointBase = "/auth";
  static const String loginEndpoint = "$authEndpointBase/login";
  static const String registerEndpoint = "$authEndpointBase/register";

  static const String criptomonedasEndpointBase = "/criptomonedas";
  static const String buscarCriptomonedasEndpoint = "$criptomonedasEndpointBase/buscar";

  static const String transaccionesEndpointBase = "/transacciones";
  static const String comprarEndpoint = "$transaccionesEndpointBase/comprar";
  static const String venderEndpoint = "$transaccionesEndpointBase/vender";
  static const String historialTransaccionesEndpoint = "$transaccionesEndpointBase/historial";
  static const String carterasEndpoint = "/carteras"; 
  static const String portfolioEndpointBase = "/portfolio"; 
  static const String rankingEndpoint = "/ranking"; 


  static const String jwtTokenKey = 'jwt_token';
  static const String userEmailKey = 'user_email_key';

  static const Duration defaultTimeout = Duration(seconds: 15);
  static const int defaultPageSize = 20;


}
