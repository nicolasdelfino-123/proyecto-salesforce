import { LightningElement, track } from 'lwc';
import Papa from '@salesforce/resourceUrl/papaparse';
import { loadScript } from 'lightning/platformResourceLoader';
import crearTanquesApex from '@salesforce/apex/CargaMasivaTanquesController.crearTanques';

export default class CargaMasivaTanques extends LightningElement {
  @track tanquesPreview = [];
  @track errorCarga = '';
  papaParseCargado = false;

  columnasTabla = [
    { label: 'Número de Serie', fieldName: 'numeroSerie' },
    { label: 'Capacidad (L)', fieldName: 'capacidad', type: 'number' },
    { label: 'Precio', fieldName: 'precio', type: 'currency' },
    { label: 'Estado', fieldName: 'estado' },
    { label: 'Tipo', fieldName: 'tipo' }
  ];

  connectedCallback() {
    if (this.papaParseCargado) return;

    loadScript(this, Papa)
      .then(() => {
        this.papaParseCargado = true;
      })
      .catch(error => {
        this.errorCarga = 'Error cargando PapaParse: ' + error;
      });
  }

  manejarArchivoCSV(event) {
    this.errorCarga = '';
    this.tanquesPreview = [];

    const archivo = event.target.files[0];
    if (!archivo) return;

    if (!this.papaParseCargado) {
      this.errorCarga = 'El parser CSV no está listo aún, intenta de nuevo.';
      return;
    }

    const lector = new FileReader();
    lector.onload = () => {
      const textoCSV = lector.result;

      window.Papa.parse(textoCSV, {
        header: true,
        skipEmptyLines: true,
        complete: (result) => {
          const datos = result.data;

          // Validación mínima para evitar errores en Apex
          if (!datos.length) {
            this.errorCarga = 'El archivo CSV está vacío.';
            return;
          }
          
          // Verificar que tenga las columnas necesarias (más flexible)
          const primeraFila = datos[0];
          if (!primeraFila.numeroSerie && !primeraFila.capacidad && !primeraFila.precio && !primeraFila.tipo) {
            this.errorCarga = 'El archivo CSV debe tener columnas: numeroSerie, capacidad, precio, tipo.';
            return;
          }

          this.tanquesPreview = datos.map(tanque => ({
            numeroSerie: tanque.numeroSerie ? tanque.numeroSerie.trim() : '',
            capacidad: Number(tanque.capacidad),
            precio: parseFloat(tanque.precio),
            estado: tanque.estado ? tanque.estado.trim() : 'Disponible', // Usar el estado del CSV o default
            tipo: tanque.tipo ? tanque.tipo.trim() : '' // Limpiar espacios del tipo
          }));

          this.errorCarga = '';
        },
        error: (error) => {
          this.errorCarga = 'Error leyendo CSV: ' + error.message;
        }
      });
    };

    lector.readAsText(archivo);
  }

  crearTanques() {
    if (!this.tanquesPreview.length) {
      this.errorCarga = 'No hay tanques para crear.';
      return;
    }

    this.errorCarga = '';

    crearTanquesApex({ tanquesJSON: JSON.stringify(this.tanquesPreview) })
      .then(() => {
        this.tanquesPreview = [];
        
        // Limpiar el input file de forma segura
        const fileInput = this.template.querySelector('lightning-input[type="file"]');
        if (fileInput) {
          fileInput.value = '';
        }
        
        alert('Tanques creados correctamente!');
      })
      .catch(error => {
        const mensajeError = error?.body?.message || error.message || 'Error desconocido';
        this.errorCarga = 'Error creando tanques: ' + mensajeError;
      });
  }
}