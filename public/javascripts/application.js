var oTable;
$(document).ready(function() {
	$('#datatable').html( '<table cellpadding="0" cellspacing="0" border="0" class="display" id="result"></table>' );
	oTable = $('#result').dataTable( {
        "oLanguage": {
            "sLengthMenu": "Показать _MENU_ результатов",
            "sInfo": "Результаты с _START_ по _END_ из _TOTAL_",
            "sSearch": "Быстрый поиск:",
            "sEmptyTable": "Маршрутов не найдено",
            "sZeroRecords": "Нет совпадающих записей",
            "oPaginate": {
					"sFirst":    "<<",
					"sPrevious": "<",
					"sNext":     ">",
					"sLast":     ">>"
				}
        },
        "bInfo": false,
        "bJQueryUI": true,
        "bAutoWidth": false,
        "sScrollY": "400px",
        "bPaginate": false,
        "sPaginationType": "full_numbers",
		"aoColumns": [
			{ "sTitle": "Компания", "sWidth" : '200' },
			{ "sTitle": "Сайт", "sWidth" : '220',
                "fnRender": function(obj) {
                    var sReturn = obj.aData[ obj.iDataColumn ];
                    return "<a href=\"" + sReturn + "\" target=\"_blank\">" + sReturn + "</a>";
                }
            },
			{ "sTitle": "Телефон", "sWidth" : '300' },
			{ "sTitle": "Время<br/> подачи", "sClass": "center" },
            { "sTitle": "Стоимость<br/> поездки", "sClass": "center" }
		]
	} );
} );