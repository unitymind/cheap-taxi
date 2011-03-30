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
        "sPaginationType": "full_numbers",
		"aoColumns": [
			{ "sTitle": "Компания", "sClass": "center" },
			{ "sTitle": "Сайт", "sClass": "center",
                "fnRender": function(obj) {
                    var sReturn = obj.aData[ obj.iDataColumn ];
                    return "<a href=\"" + sReturn + "\" target=\"_blank\">" + sReturn + "</a>";
                }
            },
			{ "sTitle": "Телефон", "sClass": "center" },
			{ "sTitle": "Время<br/> подачи", "sClass": "center" },
            { "sTitle": "Стоимость<br/> поездки", "sClass": "center" }
		]
	} );
} );