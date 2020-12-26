import "package:charts_flutter/flutter.dart" as charts;
import "package:flutter/material.dart";

import "package:fast_immutable_collections_benchmarks/fast_immutable_collections_benchmarks.dart";

class BarChart extends StatelessWidget {
  final RecordsTable recordsTable;

  const BarChart({@required this.recordsTable});

  List<StopwatchRecord> get _normalizedAgainstMax =>
      recordsTable.normalizedAgainstMax.records.toList();

  List<charts.Series<StopwatchRecord, String>> get _seriesList => [
        charts.Series<StopwatchRecord, String>(
          id: "Normalized Against\nthe Maximum Value",
          colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
          domainFn: (StopwatchRecord record, _) => record.collectionName,
          measureFn: (StopwatchRecord record, _) => record.record,
          data: _normalizedAgainstMax,
        ),
      ];

  @override
  Widget build(_) {
    return charts.BarChart(
      _seriesList,
      animate: true,
      animationDuration: const Duration(milliseconds: 100),
      barRendererDecorator: charts.BarLabelDecorator<String>(),
      domainAxis:
          const charts.OrdinalAxisSpec(renderSpec: charts.NoneRenderSpec()),
      behaviors: <charts.ChartBehavior>[
        charts.SeriesLegend(position: charts.BehaviorPosition.top),
      ],
    );
  }
}

class StackedBarChart extends StatelessWidget {
  final List<RecordsTable> recordsTables;

  const StackedBarChart({@required this.recordsTables});

  List<charts.Series<StopwatchRecord, String>> get _seriesList => [
        for (final RecordsTable recordsTable in recordsTables)
          charts.Series<StopwatchRecord, String>(
            id: "${recordsTable.config.size}",
            domainFn: (StopwatchRecord record, _) => record.collectionName,
            measureFn: (StopwatchRecord record, _) => record.record,
            data: recordsTable.normalizedAgainstMax.records.toList(),
          )
      ];

  @override
  Widget build(BuildContext context) {
    return charts.BarChart(
      _seriesList,
      animate: true,
      vertical: false,
      animationDuration: const Duration(milliseconds: 100),
      barRendererDecorator: charts.BarLabelDecorator<String>(),
      domainAxis:
          const charts.OrdinalAxisSpec(renderSpec: charts.NoneRenderSpec()),
      behaviors: <charts.ChartBehavior>[
        charts.SeriesLegend(position: charts.BehaviorPosition.top),
      ],
    );
  }
}
