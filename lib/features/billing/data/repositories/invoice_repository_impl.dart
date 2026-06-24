import 'package:fpdart/fpdart.dart';
import '../../../../core/data/hive_database.dart';
import '../../../../core/error/failure.dart';
import '../../domain/entities/invoice.dart';
import '../models/invoice_model.dart';

class InvoiceRepositoryImpl {
  Future<Either<Failure, List<Invoice>>> getInvoices() async {
    try {
      final box = HiveDatabase.invoiceBox;
      final invoices = box.values.map((model) => model.toEntity()).toList();
      invoices.sort((a, b) => b.createdAt.compareTo(a.createdAt)); // Newest first
      return Right(invoices);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  Future<Either<Failure, void>> addInvoice(Invoice invoice) async {
    try {
      final box = HiveDatabase.invoiceBox;
      final model = InvoiceModel.fromEntity(invoice);
      await box.put(model.id, model);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }
}
