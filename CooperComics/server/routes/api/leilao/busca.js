/* eslint max-len: 0 */

'use strict';

const mongoose = require('mongoose');
const dateDifference = require('date-difference');
const q = require('q');
const Cliente = require('../../../models/cliente');

function hasReachedLimitDate(auction, currentDate) {
	const limitDateReached = auction.limitDate < currentDate;

	if (limitDateReached) {
		if (auction.state === 'currentAuctions') {
			if (auction.bids.length >= 1) { // possui bids.
				auction.state = 'paymentPendingAuctions';
				auction.winningBid = auction.bids.length - 1;
				// + 5 dias para efetuar pagamento
				auction.limitDate = new Date(auction.limitDate.getTime() + (5 * 24 * 60 * 60 * 1000));

				// atualizar leilão no vendedor
				Cliente.findById(auction.seller, (err, vendedor) => {
					vendedor.updateState(auction._id, 'Vendedor', 'currentAuctions', 'paymentPendingAuctions');
					vendedor.save(() => {
						// atualizar leilões nos usuários
						const topbid = auction.bids[auction.winningBid];
						Cliente.findById(topbid.bidder, (err2, comprador) => {
							comprador.updateState(auction._id, 'Comprador', 'currentAuctions', 'paymentPendingAuctions');
							comprador.save();
							// enviar e-mail para o comprador avisando que seu lance ganhou.
						});
					});
				});
			} else {
				// não possui bids
				// cancelar o leilão
				auction.state = 'cancelledAuctions';

				// atualizar leilao no vendedor
				Cliente.findById(auction.seller, (err, vendedor) => {
					vendedor.updateState(auction._id, 'Vendedor', 'currentAuctions', 'cancelledAuctions');
					vendedor.save();
				});
			}
		} else if (auction.state === 'paymentPendingAuctions') {
			if (auction.winningBid > 0) { // index dentro de bids do lance vencedor
				auction.limitDate = new Date(auction.limitDate.getTime() + (5 * 24 * 60 * 60 * 1000));

				const topbid = auction.bids[auction.winningBid];
				Cliente.findById(topbid.bidder, (err, comprador) => {
					comprador.removeAuction(auction._id, 'Comprador', 'paymentPendingAuctions');
					comprador.save(() => {
						auction.winningBid -= 1;
						const secondbid = auction.bids[auction.winningBid];
						auction.currentPrice = auction.bids[auction.winningBid].bidValue;
						Cliente.findById(secondbid.bidder, (err2, comprador2) => {
							comprador2.updateState(auction._id, 'Comprador', 'currentAuctions', 'paymentPendingAuctions');
							comprador2.save();
							// enviar e-mail para o comprador avisando que seu lance ganhou.
						});
					});
					// enviar e-mail para o comprador avisando que seu tempo para efetuar o pagamento acabou.
				});
			} else { // não há mais lances válidos, então é necessário cancelar leilão
				auction.state = 'cancelledAuctions';
				// atualizar leilão no vendedor
				Cliente.findById(auction.seller, (err, vendedor) => {
					vendedor.updateState(auction._id, 'Vendedor', 'paymentPendingAuctions', 'cancelledAuctions');
					vendedor.save(() => {
						const topbid = auction.bids[0];
						Cliente.findById(topbid.bidder, (err2, comprador) => {
							comprador.removeAuction(auction._id, 'Comprador', 'paymentPendingAuctions');
							comprador.save();
							// enviar e-mail para o comprador avisando que tempo para efetuar o pagamento acabou.
						});
					});
				});
			}
		}

		auction.save();
	}

	return auction;
}

function checkAuctions(auctions, listAll) {
	const response = [];
	const currentDate = new Date();

	auctions.forEach((elem) => {
		const oldState = elem.state;

		const auction = hasReachedLimitDate(elem, currentDate);
		const limitdate = new Date(auction.limitDate);

		auction.timeLeft = dateDifference(new Date(), limitdate, { compact: true });

		const hours = (`0${limitdate.getHours()}`).slice(-2);
		const mins = (`0${limitdate.getMinutes()}`).slice(-2);
		const seconds = (`0${limitdate.getSeconds()}`).slice(-2);

		auction.limitDateString = `${hours}:${mins}:${seconds} ${limitdate.getFullYear()}-${(`0${limitdate.getMonth() + 1}`).slice(-2)}-${(`0${limitdate.getDate()}`).slice(-2)}`;
		if (auction.state === oldState || listAll) {
			response.push(auction);
		}
	});

	return response;
}

function findAuctions(auctions, modules, response, type, subtype) {
	const promise = modules.Leilao.find({
		_id: { $in:
			auctions,
		},
	}).populate('book').exec((err, docs) => {
		const obj = checkAuctions(docs, false);
		response[type][subtype] = docs;
	});

	return promise;
}

module.exports = function leilao(app, modules) {
	app.get('/api/leilao/buscar', (req, res) => {
		if (req.query.listAll === 'true') {
			if (req.query.state) {
				if (req.user._type === 'Administrador') {
					modules.Leilao.find({ state: req.query.state }).populate('book seller').exec((err, docs) => {
						if (err) {
							res.status(err.status).send(err);
						}

						const auctions = checkAuctions(docs, false);
						res.send(auctions);
					});
				} else {
					modules.Leilao.find({ state: req.query.state }).populate('book').exec((err, docs) => {
						if (err) {
							res.status(err.status).send(err);
						}

						const auctions = checkAuctions(docs, false);
						res.send(auctions);
					});
				}
			} else if (req.body.auctions) {
				modules.Leilao.find({
					_id: { $in: req.body.auctions },
				}).populate('book').exec((err, docs) => {
					if (err) {
						res.status(err.status).send(err);
					}

					const auctions = checkAuctions(docs, false);
					res.send(auctions);
				});
			} else if (req.body.userAuctions) {
				const obj = req.body.userAuctions;
				const response = {
					Comprador: {
						currentAuctions: [],
						finalizedAuctions: [],
						paymentPendingAuctions: [],
						paymentDoneAuctions: [],
					},
					Vendedor: {
						currentAuctions: [],
						finalizedAuctions: [],
						paymentDoneAuctions: [],
						paymentPendingAuctions: [],
						validationPendingAuctions: [],
						cancelledAuctions: [],
					},
				};

				const promises = [
					findAuctions(obj.Comprador.currentAuctions, modules, response, 'Comprador', 'currentAuctions'),
					findAuctions(obj.Comprador.paymentPendingAuctions, modules, response, 'Comprador', 'paymentPendingAuctions'),
					findAuctions(obj.Comprador.paymentDoneAuctions, modules, response, 'Comprador', 'paymentDoneAuctions'),
					findAuctions(obj.Comprador.finalizedAuctions, modules, response, 'Comprador', 'finalizedAuctions'),

					findAuctions(obj.Vendedor.currentAuctions, modules, response, 'Vendedor', 'currentAuctions'),
					findAuctions(obj.Vendedor.finalizedAuctions, modules, response, 'Vendedor', 'finalizedAuctions'),
					findAuctions(obj.Vendedor.paymentPendingAuctions, modules, response, 'Vendedor', 'paymentPendingAuctions'),
					findAuctions(obj.Vendedor.paymentDoneAuctions, modules, response, 'Vendedor', 'paymentDoneAuctions'),
					findAuctions(obj.Vendedor.validationPendingAuctions, modules, response, 'Vendedor', 'validationPendingAuctions'),
					findAuctions(obj.Vendedor.cancelledAuctions, modules, response, 'Vendedor', 'cancelledAuctions'),
				];


				q.all(promises).then(() => {
					res.send(response);
				});
			} else {
				modules.Leilao.find().populate('book').exec((err, docs) => {
					if (err) {
						res.status(err.status).send(err);
					}

					const auctions = checkAuctions(docs, true);
					res.send(auctions);
				});
			}
		} else if (!req.query.type && !req.query.id) {
			res.status(400).send('listAll is false or undefined, so type or id needs to be defined.');
		} else if (req.query.id) {
			if (mongoose.Types.ObjectId.isValid(req.query.id)) {
				modules.Leilao.findById(req.query.id).populate('book').exec((err, doc) => {
					if (err) {
						res.status(400).send(err.message);
					}

					if (!doc) {
						res.status(404).send(doc);
					} else {
						const docs = [];
						docs.push(doc);

						const auctions = checkAuctions(docs, false);
						res.json(auctions[0]);
					}
				});
			} else {
				res.status(400).send(`Invalid id ${req.query.id} informed.`);
			}
		} else {
			const searchType = req.query.type;

			if (searchType !== 't' && searchType !== 'e' && searchType !== 'te' && searchType !== 'et') {
				res.status(406).send(`Invalid type ${searchType} informed. Needs to be 't' (title), 'e' (edition), 'te' or 'et' (title and edition)`);
			}

			if (searchType === 't') {
				modules.Livro.find({ title: req.query.title }).populate('auction').exec((err, docs) => {
					if (err) {
						res.status(err.status).send(err);
					}

					res.send(docs);
				});
			} else if (searchType === 'e') {
				modules.Livro.find({ edition: req.query.edition }).populate('auction').exec((err, docs) => {
					if (err) {
						res.status(err.status).send(err);
					}

					res.send(docs);
				});
			} else if (searchType === 'te' || searchType === 'et') {
				modules.Livro.find({ title: req.query.title, edition: req.query.edition }).populate('auction').exec((err, docs) => {
					if (err) {
						res.status(err.status).send(err);
					}

					res.send(docs);
				});
			} else {
				res.status(406).send(`Invalid type ${searchType} informed. Needs to be 't' (title), 'e' (edition), 'te' or 'et' (title and edition)`);
			}
		}
	});
};
