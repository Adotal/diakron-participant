
import 'package:diakron_participant/data/repositories/user/participant_repository.dart';
import 'package:diakron_participant/models/users/participant.dart';
import 'package:diakron_participant/utils/command.dart';
import 'package:diakron_participant/utils/result.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

class ProfileViewmodel extends ChangeNotifier {
  ProfileViewmodel({required ParticipantRepository participantRepository})
    : _participantRepository = participantRepository {
    load = Command0(_load)..execute();
  }
  final ParticipantRepository _participantRepository;
  Participant? _participant;
  Participant? get participant => _participant;
  late Command0 load;
  final logger = Logger();

  Future<Result> _load() async {
    try {
      final result = await _participantRepository.getParticipant();
      switch (result) {
        case Ok<Participant>():
          _participant = result.value;

          logger.w(_participant.toString());
          return Result.ok('value');
        case Error<Participant>():
          return Result.error(result.error);
      }
    } finally {
      notifyListeners();
    }
  }
}
