@IsTest
public class CargaMasivaTanquesControllerTest {
  
  @IsTest
  static void testCrearTanques() {
    // Preparar JSON de prueba con 2 tanques
    List<Map<String, Object>> tanquesPrueba = new List<Map<String, Object>>();
    
    Map<String, Object> tanque1 = new Map<String, Object>{
      'numeroSerie' => 'ABC123',
      'capacidad' => 1000,
      'precio' => 5000.50,
      'estado' => 'Disponible',
      'tipo' => 'TipoA'
    };
    
    Map<String, Object> tanque2 = new Map<String, Object>{
      'numeroSerie' => 'DEF456',
      'capacidad' => 2000,
      'precio' => 10000,
      'estado' => 'Disponible',
      'tipo' => 'TipoB'
    };
    
    tanquesPrueba.add(tanque1);
    tanquesPrueba.add(tanque2);
    
    // Convertir a JSON string
    String tanquesJSON = JSON.serialize(tanquesPrueba);
    
    // Ejecutar método bajo prueba
    Test.startTest();
    CargaMasivaTanquesController.crearTanques(tanquesJSON);
    Test.stopTest();
    
    // Validar que los registros se hayan insertado correctamente
    List<Tanque__c> tanquesInsertados = [SELECT Numero_de_Serie__c, Capacidad_Litros__c, Precio__c, Estado__c, Tipo_de_Tanque__c FROM Tanque__c WHERE Numero_de_Serie__c IN ('ABC123', 'DEF456')];
    
    System.assertEquals(2, tanquesInsertados.size(), 'Deben haberse insertado 2 tanques');
    
    // Validar campo por campo (ejemplo del primero)
    Tanque__c t1 = tanquesInsertados[0];
    System.assertEquals('ABC123', t1.Numero_de_Serie__c);
    System.assertEquals(1000, t1.Capacidad_Litros__c);
    System.assertEquals(5000.50, t1.Precio__c);
    System.assertEquals('Disponible', t1.Estado__c);
    System.assertEquals('TipoA', t1.Tipo_de_Tanque__c);
  }
  
  @IsTest
  static void testCrearTanquesConJSONVacio() {
    // Probar que pasar JSON vacío no falle
    Test.startTest();
    CargaMasivaTanquesController.crearTanques('[]');
    Test.stopTest();
    
    // No debería haber tanques insertados
    List<Tanque__c> tanquesInsertados = [SELECT Id FROM Tanque__c];
    System.assertEquals(0, tanquesInsertados.size(), 'No debe insertar tanques con JSON vacío');
  }
}
